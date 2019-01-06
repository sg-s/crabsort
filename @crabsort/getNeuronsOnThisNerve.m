

function N = getNeuronsOnThisNerve(self, channel)

N = {};

if nargin == 1
	assert(~isempty(self.channel_to_work_with),'which channel?')
	channel = self.channel_to_work_with;
end

if isempty(self.common.data_channel_names{channel})
	return
end

nerve_name =  self.common.data_channel_names{channel};

N = self.nerve2neuron.(nerve_name);

