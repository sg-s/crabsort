% merges all .crabsort files and returns spike time info

function data = consolidate(varargin)


% options and defaults
options.DataDir = pwd;
options.dt = 1e-3; % 1 ms
options.nerves = {};
options.neurons = {};
options.stack = false;
options.DataFun = {};
options.ChunkSize = NaN; % seconds 

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




% figure out the experiment idx from the folder name
[~,exp_dir]=fileparts(options.DataDir);
exp_dir = str2double(strrep(exp_dir,'_',''));
assert(~isnan(exp_dir),'Could not determine experiment idx. Experiment_idx should be a number, and the folder that contains the data should have a name which is a number.')

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
parfor i = 1:length(data)
	data(i) = crabsort.analysis.readData(allfiles(i), options,data(i));
end


% set the time_offsets for all the data
for i = 2:length(data)
	data(i).time_offset = data(i-1).time_offset + data(i-1).T;
end


if options.stack

	disp('Stacking data...')

	fn = fieldnames(data);
	sdata = struct;

	for j = 1:length(fn)
		sdata.(fn{j}) = [];
	end

	for i = 1:length(data)
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


end