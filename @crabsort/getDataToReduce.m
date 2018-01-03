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

data_to_reduce = [];

if self.handles.spike_shape_control.Value
	data_to_reduce = self.getSnippets(self.channel_to_work_with);
end

if self.handles.time_before_control.Value
	% first, we need to figure out what nerves to compare to
	if isempty(self.handles.time_before_nerves.String)
		nerves = fieldnames(self.spikes);
	else
		nerves = self.handles.time_after_nerves.String;
	end  

	if ~iscell(nerves)
		nerves = {nerves};
	end


	% get times to closest spikes on other nerves in the past
	relative_times = self.measureTimesToIdentifiedSpikes(nerves,'future');

	data_to_reduce = [data_to_reduce; relative_times];
end

if self.handles.time_after_control.Value
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