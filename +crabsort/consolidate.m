% crabsort.consolidate
% 
% Once you have sorted spikes, use this method to combine 
% all data from all files into a single variable
%
% **Syntax**
%
% ```
% crabsort.consolidate(ExpName,'neurons',{'PD','LP'})
% crabsort.consolidate(ExpName,...'DataDir',/path/to/data)
% crabsort.consolidate(ExpName,...'DataFun',{@function1, @function2,...})
% crabsort.consolidate(ExpName,...'dt',1e-3)
% crabsort.consolidate(ExpName,...'stack',true)
% crabsort.consolidate(ExpName,...,'ChunkSize',20)
% ```
%
% Chunking may throw away data at the end if it doesn't fit into
% a full chunk
%
% the 'nerves' option is not used by anything in consolidate,
% but may affect the behaviour of functions in DataFun


function data = consolidate(ExpName, varargin)

spikesfolder = getpref('crabsort','store_spikes_here');


% options and defaults
options.DataDir = pwd;
options.dt = 1e-3; % 1 ms
options.neurons = {};
options.stack = false;
options.DataFun = {};
options.ChunkSize = NaN; % seconds 
options.nerves = {};
options.UseParallel = true;
options.ParseMetadata = true;

% validate and accept options
options = corelib.parseNameValueArguments(options,varargin{:});


options.neurons = sort(options.neurons);

% figure out where the spikes are, and where the data is
spikes_loc = fullfile(getpref('crabsort','store_spikes_here'),ExpName);
allfiles = dir(fullfile(spikes_loc, '*.crabsort'));

data = [];

if exist(spikes_loc,'file') == 0
	return
end



metadata_file = dir(fullfile(spikesfolder,ExpName,'*.txt'));
metadata_file = metadata_file(~[metadata_file.isdir]);



% hash
cfiles = dir(fullfile(spikes_loc,'*.crabsort'));
if isempty(cfiles)
	return
end
for i = length(cfiles):-1:1
	load(fullfile(cfiles(i).folder,cfiles(i).name),'-mat')
	H{i} = hashlib.md5hash([structlib.md5hash(crabsort_obj.spikes) structlib.md5hash(crabsort_obj.ignore_section)]);
end
H1 = hashlib.md5hash(vertcat(H{:}));
options2 = rmfield(options,'DataDir');
H2 = structlib.md5hash(options2);


% also hash metadata
H3 =  '';
if ~isempty(metadata_file) && options.ParseMetadata

	metadata = crabsort.parseMetadata(fullfile(metadata_file(1).folder, metadata_file(1).name),allfiles);

	H3 = structlib.md5hash(metadata);
end

H = hashlib.md5hash([H1 H2 H3]);
cache_name = [H '.cache'];
cache_name = fullfile(spikes_loc,cache_name);


if exist(cache_name,'file') == 2
	load(cache_name,'data','-mat')

	return
end





if isempty(allfiles)
	error(['No spikes found for this exp: ' ExpName])
end

if ~iscell(options.DataFun)
	error('DataFun must be a cell array of function handles')
end

% load the common data
load([allfiles(1).folder filesep 'crabsort.common'],'-mat','common')


assert(~isempty(options.neurons),'neurons must be specified')
assert(iscell(options.nerves),'Expected nerves to be a cell array')




% figure out the experiment idx from the folder name


data = struct;
for i = length(allfiles):-1:1
	for j = 1:length(options.neurons)
		data(i).(options.neurons{j}) = [];
	end
	data(i).time_offset = 0;
	data(i).T = NaN;
	data(i).experiment_idx = categorical(cellstr(ExpName));
	data(i).mask = [];
	data(i).filename = '';

	for j = 1:length(options.neurons)
		data(i).([options.neurons{j} '_channel']) = categorical(NaN);
	end


	% make variables for the DataFun
	for j = 1:length(options.DataFun)
		variable_names = corelib.argOutNames(char(options.DataFun{j}));
		for k = 1:length(variable_names)
			data(i).(strtrim(variable_names{k})) = [];
		end
	end



end




% load all the data into the data structure
% in parallel
if options.UseParallel
	parfor i = 1:length(data)
		data(i) = crabsort.analysis.readData(allfiles(i), options,data(i));
	end
else
	for i = length(data):-1:1
		data(i) = crabsort.analysis.readData(allfiles(i), options,data(i));
	end
end

for i = 1:length(data)
	data(i).filename = categorical({allfiles(i).name(1:min(strfind(allfiles(i).name,'.'))-1)});
end


if length(unique([data.filename])) ~= length(data)

	
	url = ['matlab:cd(' char(39) allfiles(1).folder char(39) ')'];
    fprintf(['\n\nThere are more .crabsort files than I expect. The most common reason for this \n is if there is a .crabsort file for a .crab file, \n and another one for a .ABF file, for example. \n To fix this, manually delete the ones you do not want from the \nstore_spikes_here folder. \n\n Click <a href = "' url '">here</a>  to go to that folder\n\n\n'])


	error('Too many crabsort files')
end


% set the time_offsets for all the data

for i = 2:length(data)

	% only increment if files are consecutive
	this_file_idx = strsplit(char(data(i).filename),'_');
	this_file_idx = str2double(this_file_idx{end});

	prev_file_idx = strsplit(char(data(i-1).filename),'_');
	prev_file_idx = str2double(prev_file_idx{end});


	if this_file_idx == prev_file_idx + 1
		data(i).time_offset = data(i-1).time_offset + data(i-1).T;
	else
		data(i).time_offset = 0;
	end

end







% parse metadata if exists

if ~isempty(metadata_file) && options.ParseMetadata



	metadata = crabsort.parseMetadata(fullfile(metadata_file(1).folder, metadata_file(1).name),allfiles);

	assert(isfield(metadata,'experimenter'),'Metadata is missing a required field: experimenter')

	assert(length(metadata.experimenter) == length(data),'Length of data and metadata do not match')

	% add this to data
	mfn = fieldnames(metadata);


	for i = 1:length(data)
		for j = 1:length(mfn)
			data(i).(mfn{j}) = metadata.(mfn{j})(i);
		end
	end

	clearvars metadata

end



% add temperature metadata if it exists
metadata_file = dir(fullfile(spikesfolder,ExpName,'*.metadata'));


if ~isempty(metadata_file) 


	load(fullfile(metadata_file.folder,metadata_file.name),'-mat')

	% strip file extensions from metadata
	for j = 1:length(metadata)
		[~,metadata(j).file_name]=fileparts(metadata(j).file_name);
	end

	for i = 1:length(data)
		idx = find(strcmp({metadata.file_name},char(data(i).filename)));
		if isempty(idx)
			continue
		end
		data(i).temperature = metadata(idx).temperature;

	end

end


% propagate temperate to next file
% if temperature is a scalar
if isfield(data,'temperature')
	for i = 2:length(data)
		if isscalar(data(i).temperature) && isnan(data(i).temperature)
			data(i).temperature = data(i-1).temperature;
		end
	end
end



if options.stack

	fprintf('Stacking data...')
	data = crabsort.analysis.stack(data, options);
	corelib.cprintf('green','[DONE]\n')

end


% chunk
if ~isnan(options.ChunkSize)
	fprintf('Chunking data...')

	cdata = crabsort.analysis.chunk(data,options);

	corelib.cprintf('green','[DONE]\n')

	data = cdata;	


end


% save
save(cache_name,'data')