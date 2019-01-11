% merges all .crabsort files and returns spike time info

function data = consolidate(varargin)


% options and defaults
options.data_dir = pwd;
options.dt = 1e-3; % 1 ms
options.nerves = {};
options.neurons = {};

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
load([allfiles(1).folder filesep 'crabsort.common'],'-mat')

req_nerve_idx = [];
for i = length(options.nerves):-1:1
	if ~any(strcmp(common.data_channel_names,options.nerves{i}))
		error('Could not find required nerve in common data')
	end

	req_nerve_idx(i) = find(strcmp(common.data_channel_names,options.nerves{i}));

end

data = struct;
for i = length(allfiles):-1:1
	for j = 1:length(options.neurons)
		data(i).(options.neurons{j}) = [];
	end
	data(i).time_offset = 0;
end


for i = 1:length(allfiles)
	load([allfiles(i).folder filesep allfiles(i).name],'-mat')

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

	T = self.raw_data_size(1)*self.dt;
	if i > 1
		data(i).time_offset = data(i-1).time_offset + T;
	end


end

