% merges all .crabsort files and returns spike time info

function data = consolidate(varargin)


% options and defaults
options.data_dir = pwd;
options.dt = 1e-3; % 1 ms
options.nerves = {};
options.neurons = {};
options.stack = false;
options.data_fun = {};

% validate and accept options
if mathlib.iseven(length(varargin))
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

if ~iscell(options.data_fun)
	error('data_fun must be a cell array of function handles')
end

% load the common data
load([allfiles(1).folder filesep 'crabsort.common'],'-mat','common')


assert(~isempty(options.neurons),'neurons must be specified')




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



% check that all files are sorted
fatal = false;
for i = 1:length(allfiles)
	load([allfiles(i).folder filesep allfiles(i).name],'-mat','crabsort_obj')

	self = crabsort_obj;


	% check that the channel_stages for req nerves are OK
	if sum(self.channel_stage == 3) >= length(options.neurons)
	else
		corelib.cprintf('red',['Some channels not sorted on ' allfiles(i).name '\n'])
		fatal = true;
	end
end


if fatal
	error('Some files are not sorted')
else
	corelib.cprintf('green','All files sorted')
end

for i = 1:length(allfiles)
	load([allfiles(i).folder filesep allfiles(i).name],'-mat','crabsort_obj')

	disp(allfiles(i).name)

	self = crabsort_obj;



	for j = 1:length(options.neurons)
		possible_spiketimes = {};
		this_neuron = options.neurons{j};

		% find all possible places where this neuron could be
		if ~isstruct(self.spikes)
			keyboard
		end
		fn = fieldnames(self.spikes);
		for k = 1:length(fn)
			neurons_here = fieldnames(self.spikes.(fn{k}));
			if any(strcmp(neurons_here,this_neuron))
				possible_spiketimes{end+1} = self.spikes.(fn{k}).(this_neuron);
			end
		end

		% does this neuron occur on multiple nerves?

		if length(possible_spiketimes) > 1
			% blindly pick the one with the most spikes
			[~,pick_me] = max(cellfun(@length,possible_spiketimes));
			spiketimes = possible_spiketimes{pick_me};
		elseif length(possible_spiketimes) == 1
			spiketimes = possible_spiketimes{1};
		else
			spiketimes = [];
		end

		spiketimes  = round(spiketimes*self.dt*(1/options.dt));
		spiketimes = spiketimes*options.dt;
		data(i).(this_neuron) = spiketimes;


	end

	% reconstruct mask
	self.reconstructMaskFromIgnoreSection;

	mask = min(self.mask,[],2);

	S = round(options.dt/self.dt);
	mask = mask(1:S:end);
	data(i).mask = mask;

	
	

	data(i).T = self.raw_data_size(1)*self.dt;

	if i > 1
		data(i).time_offset = data(i-1).time_offset + data(i-1).T;
	end


	if ~isempty(options.data_fun)
		self.file_name = strrep(allfiles(i).name,'.crabsort','');
		self.path_name = allfiles(i).folder;
		self.loadFile;
		for j = 1:length(options.data_fun)
			
			
			variable_names = corelib.argOutNames(char(options.data_fun{j}));
			outputs = cell(1,length(variable_names));
			[outputs{:}] = options.data_fun{j}(self, options);

			for k = 1:length(variable_names)
				data(i).(strtrim(variable_names{k})) = outputs{k};
			end

		end
	end

	clear self outputs 

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