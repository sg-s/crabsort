% crabsort.consolidate
% 
% Once you have sorted spikes, use this method to combine 
% all data from all files into a single variable
%
% **Syntax**
%
% ```
% crabsort.consolidate('neurons',{'PD','LP'})
% crabsort.consolidate(...'DataDir',/path/to/data)
% crabsort.consolidate(...'DataFun',{@function1, @function2,...})
% crabsort.consolidate(...'dt',1e-3)
% crabsort.consolidate(...'stack',true)
% crabsort.consolidate(...,'ChunkSize',20)
% ```
%
% Chunking may throw away data at the end if it doesn't fit into
% a full chunk
%
% the 'nerves' option is not used by anything in consolidate,
% but may affect the behaviour of functions in DataFun


function data = consolidate(varargin)

% options and defaults
options.DataDir = pwd;
options.dt = 1e-3; % 1 ms
options.neurons = {};
options.stack = false;
options.DataFun = {};
options.ChunkSize = NaN; % seconds 
options.nerves = {};
options.UseParallel = true;

% validate and accept options
options = corelib.parseNameValueArguments(options,varargin{:});

allfiles = dir([options.DataDir filesep '*.crabsort']);

if isempty(allfiles)
	error(['No data found in this directory: ' options.DataDir])
end

if ~iscell(options.DataFun)
	error('DataFun must be a cell array of function handles')
end

% load the common data
load([allfiles(1).folder filesep 'crabsort.common'],'-mat','common')


assert(~isempty(options.neurons),'neurons must be specified')
assert(iscell(options.nerves),'Expected nerves to be a cell array')




% figure out the experiment idx from the folder name
[~,exp_dir]=fileparts(options.DataDir);
exp_dir = categorical(cellstr(exp_dir));


data = struct;
for i = length(allfiles):-1:1
	for j = 1:length(options.neurons)
		data(i).(options.neurons{j}) = [];
	end
	data(i).time_offset = 0;
	data(i).T = NaN;
	data(i).experiment_idx = exp_dir;
	data(i).mask = [];
	data(i).filename = '';


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



% set the time_offsets for all the data

for i = 2:length(data)

	% only increment if files are consequtive
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
metadata_file = dir([options.DataDir filesep '*.txt']);
if ~isempty(metadata_file)
	metadata = crabsort.parseMetadata([metadata_file(1).folder filesep metadata_file(1).name],allfiles);


	% add this to data
	mfn = fieldnames(metadata);


	for i = 1:length(data)
		for j = 1:length(mfn)
			data(i).(mfn{j}) = metadata.(mfn{j})(i);
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
	if length(data) == 1
		% assume data has been stacked, and now we need to chunk
		cdata = crabsort.analysis.chunk(data,options);

	else
		% data hasn't been stacked. Still need to chunk
		cdata =  crabsort.analysis.chunk(data(1),options);
		fn = fieldnames(cdata);


		for i = 2:length(data)

			if max(data(i).time_offset) < options.ChunkSize
				continue
			end


			temp = crabsort.analysis.chunk(data(i),options);
			% glom them all together
			N2 = size(temp.experiment_idx,1);
			
			for j = 1:length(fn)
				if size(temp.(fn{j}),1) == N2
					cdata.(fn{j}) = [cdata.(fn{j}); temp.(fn{j})];
				else
					cdata.(fn{j}) = [cdata.(fn{j}) temp.(fn{j})];
				end

			end
		end

		
	end


	corelib.cprintf('green','[DONE]\n')

	data = cdata;	


end
