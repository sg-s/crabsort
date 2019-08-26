

function N = getNeuronsOnThisNerve(self, channel)

if self.verbosity > 9
	disp(mfilename)
end

N = {};

if nargin == 1
	assert(~isempty(self.channel_to_work_with),'which channel?')
	channel = self.channel_to_work_with;
end

if isempty(self.common.data_channel_names{channel})
	return
end

nerve_name =  self.common.data_channel_names{channel};

if ~isfield(self.nerve2neuron,nerve_name)
	return
end

N = self.nerve2neuron.(nerve_name);

