function zeroSpikes(self,~,~)

channel = self.channel_to_work_with;

if isempty(channel)
	return

end


nerve_name = self.common.data_channel_names{channel};

if strcmp(upper(nerve_name),nerve_name)
	% intracellular
	neurons = {nerve_name};
else
	neurons = self.nerve2neuron.(nerve_name);
end

if ~iscell(neurons)
	neurons = {neurons};
end
	
for i = 1:length(neurons)
	self.spikes.(nerve_name).(neurons{i}) = [];
end


% set the channel stage too
self.channel_stage(channel) = 3;
self.showSpikes(channel);

self.say('Marking this channel as having no spikes!')