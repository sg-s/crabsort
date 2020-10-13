% checks if  channel is intracellular

function TF = isIntracellular(self, channel)

arguments
	self (1,1) crabsort
	channel (1,1) double 
end

if self.verbosity > 9
	disp(mfilename)
end

TF = any(isstrprop(self.common.data_channel_names{channel},'upper'));