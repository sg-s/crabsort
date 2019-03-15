function zeroSpikes(self,~,~)

channel = self.channel_to_work_with;

if isempty(channel)
	return

end


nerve_name = self.common.data_channel_names{channel};
neurons = self.nerve2neuron.(nerve_name);

if ~iscell(neurons)
	neurons = {neurons};
end
	
for i = 1:length(neurons)
	self.spikes.(nerve_name).(neurons{i}) = [];
end


% set the channel stage too
self.channel_stage(channel) = 3;
self.showSpikes(channel);