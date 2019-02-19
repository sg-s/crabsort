% checks if  channel is intracellular

function TF = isIntracellular(self, channel)

TF = any(isstrprop(self.common.data_channel_names{channel},'upper'));