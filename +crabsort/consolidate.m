% merges all .crabsort files and returns spike time info

function data = consolidate(varargin)


% options and defaults
options.data_dir = pwd;
options.dt = 1e-3; % 1 ms
options.nerves = {};
options.neurons = {};
options.stack = false;

% validate and accept options
if iseven(length(varargin))
	for ii = 1:2:length(varargin)-1
	temp = varargin{ii};
    if ischar(temp)
    	if ~any(find(strcmp(temp,fieldnames(options))))
    		disp(['Unknown option: ' temp])
    		disp('The allowed options are:')
    		disp(fieldnames(options))
    		error('UNKNOWN OPTION')
    	else
    		options.(temp) = varargin{ii+1};
    	end
    end
end
elseif isstruct(varargin{1})
	% should be OK...
	options = varargin{1};
else
	error('Inputs need to be name value pairs')
end

allfiles = dir([options.data_dir filesep '*.crabsort']);

if isempty(allfiles)
	error('No data found')
end

% load the common data
load([allfiles(1).folder filesep 'crabsort.common'],'-mat','common')


assert(~isempty(options.neurons),'neurons must be specified')

if isempty(options.nerves)
	% load the first crabsort file
	load([allfiles(1).folder filesep allfiles(1).name],'-mat','crabsort_obj')
	spikes = crabsort_obj.spikes;

	% look for these neurons in all fields of spikes
	nerve_names = fieldnames(spikes);

	for i = 1:length(nerve_names)
		neurons = fieldnames(spikes.(nerve_names{i}));
		for j = 1:length(options.neurons)
			if any(strcmp(neurons,options.neurons{j}))
				options.nerves{j} = nerve_names{i};
			end
		end
	end
end

for i = 1:length(options.neurons)
	assert(~isempty(options.nerves{i}),'Could not resolve nerve')
end

req_nerve_idx = [];
for i = length(options.nerves):-1:1
	if ~any(strcmp(common.data_channel_names,options.nerves{i}))
		error('Could not find required nerve in common data')
	end

	req_nerve_idx(i) = find(strcmp(common.data_channel_names,options.nerves{i}));

end

% figure out the experiment idx from the folder name
[~,exp_dir]=fileparts(options.data_dir);
exp_dir = str2double(strrep(exp_dir,'_',''));
assert(~isnan(exp_dir),'Could not determine experiment idx')

data = struct;
for i = length(allfiles):-1:1
	for j = 1:length(options.neurons)
		data(i).(options.neurons{j}) = [];
	end
	data(i).time_offset = 0;
	data(i).T = NaN;
	data(i).experiment_idx = exp_dir;
end


for i = 1:length(allfiles)
	load([allfiles(i).folder filesep allfiles(i).name],'-mat','crabsort_obj')

	self = crabsort_obj;

	% check that the channel_stages for req nerves are OK
	assert(all(self.channel_stage(req_nerve_idx)>=3),['At least one nerve not sorted in this file: ' allfiles(i).name])

	for j = 1:length(options.nerves)
		this_nerve = self.spikes.(options.nerves{j});
		for k = 1:length(options.neurons)
			if isfield(this_nerve,options.neurons{k})
				spiketimes  = round(this_nerve.(options.neurons{k})*self.dt*(1/options.dt));
				spiketimes = spiketimes*options.dt;

				data(i).(options.neurons{k}) = spiketimes;
			end
		end

	end

	
	

	data(i).T = self.raw_data_size(1)*self.dt;

	if i > 1
		data(i).time_offset = data(i-1).time_offset + data(i-1).T;
	end


end



if options.stack


	sdata = struct;

	for j = 1:length(neurons)
		sdata.(neurons{j}) = [];
	end

	for i = 1:length(data)
		for j = 1:length(neurons)
			sdata.(neurons{j}) = [sdata.(neurons{j}); data(i).time_offset+data(i).(neurons{j})];
		end

	end
	data = sdata;
	return
end



m = [options.data_dir filesep 'metadata.txt'];
if exist(m,'file') == 2
	metadata = crabsort.parseMetadata(m,allfiles);
	fn = fieldnames(metadata);

	for j = 1:length(fn)
		if ~isfield(data(1),fn{j})
			data(1).(fn{j}) = [];
		end
			
	end

	for i = 1:length(allfiles)
		for j = 1:length(fn)
			data(i).(fn{j}) = metadata.(fn{j})(i);
		end
	end
else
	return
end