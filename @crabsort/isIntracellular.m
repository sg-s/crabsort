% checks if  channel is intracellular

function TF = isIntracellular(self, channel)

if self.verbosity > 9
	disp(mfilename)
end

TF = any(isstrprop(self.common.data_channel_names{channel},'upper'));