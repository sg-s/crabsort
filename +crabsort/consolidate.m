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
	error('No data found')
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


	% make variables for the DataFun
	for j = 1:length(options.DataFun)
		variable_names = corelib.argOutNames(char(options.DataFun{j}));
		for k = 1:length(variable_names)
			data(i).(strtrim(variable_names{k})) = [];
		end
	end



end



% check that all files are sorted
fatal = crabsort.checkSorted(allfiles, options.neurons);


if fatal
	error('Some files are not sorted')
else
	corelib.cprintf('green','All files sorted\n')
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


% set the time_offsets for all the data
for i = 2:length(data)
	data(i).time_offset = data(i-1).time_offset + data(i-1).T;
end


if options.stack

	fprintf('Stacking data...')

	fn = fieldnames(data);
	sdata = struct;

	for j = 1:length(fn)
		sdata.(fn{j}) = [];
	end

	for i = 1:length(data)
		corelib.textbar(i,length(data))
		for j = 1:length(fn)
			if any(strcmp(fn{j},options.neurons))
				sdata.(fn{j}) = [sdata.(fn{j}); data(i).time_offset+data(i).(fn{j})];
			elseif strcmp(fn{j},'T')
			elseif strcmp(fn{j},'time_offset')
			elseif strcmp(fn{j},'experiment_idx')
				sdata.experiment_idx = data(i).experiment_idx;
			else

				% check size
				this_variable = data(i).(fn{j});
				if length(this_variable) ~= length(data(i).mask)
					this_variable = this_variable*(data(i).mask*0 + 1);
				end
				sdata.(fn{j}) = [sdata.(fn{j}); this_variable];
				
			end
		end
	end


	data = sdata;
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
