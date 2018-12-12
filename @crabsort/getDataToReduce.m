% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% populates the data_to_reduce property of crabsort
% using the options on hand 

function getDataToReduce(self)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


data_to_reduce = [];

if self.handles.spike_shape_control.Value

	if self.verbosity > 5
		disp(['[' mfilename '] Using spike shape...'])
	end

	data_to_reduce = self.getSnippets(self.channel_to_work_with);
end


if self.handles.multi_channel_control.Value

	if self.verbosity > 5
		disp(['[' mfilename '] Using multi-channel spike shape...'])
	end

	% let's make sure we have the delays computed
	self.estimateDelay;

	if ~isempty(self.handles.multi_channel_control_text.String)
		
		N = strsplit(self.handles.multi_channel_control_text.String,',');

		if length(N) > 1
			disp('More than one nerve chosen, not coded')
			keyboard
		end

		for i = 1:length(N)
			assert(any(strcmp(self.common.data_channel_names,N{i})),'Unknown channel name')
			this_channel = find(strcmp(self.common.data_channel_names,N{i}));

			D = self.common.delays(self.channel_to_work_with,this_channel);

			spiketimes = find(self.putative_spikes(:,self.channel_to_work_with)) + D;

			data_to_reduce = [data_to_reduce; self.getSnippets(this_channel, spiketimes)];

		end
	end


end

if self.handles.time_before_control.Value


	if self.verbosity > 5
		disp(['[' mfilename '] Using time before information...'])
	end

	% first, we need to figure out what nerves to compare to
	if isempty(self.handles.time_before_nerves.String)
		nerves = fieldnames(self.spikes);
	else
		nerves = self.handles.time_before_nerves.String;
	end  

	if ~iscell(nerves)
		nerves = {nerves};
	end


	% get times to closest spikes on other nerves in the past
	relative_times = self.measureTimesToIdentifiedSpikes(nerves,'future');

	data_to_reduce = [data_to_reduce; relative_times];
end

if self.handles.time_after_control.Value

	if self.verbosity > 5
		disp(['[' mfilename '] Using time after information...'])
	end

	% first, we need to figure out what nerves to compare to
	if isempty(self.handles.time_after_nerves.String)
		nerves = fieldnames(self.spikes);
	else
		nerves = self.handles.time_after_nerves.String;
	end 

	if ~iscell(nerves)
		nerves = {nerves};
	end


	% get times to closest spikes on other nerves in the past
	relative_times = self.measureTimesToIdentifiedSpikes(nerves,'past');

	data_to_reduce = [data_to_reduce; relative_times];

end

self.data_to_reduce = data_to_reduce;