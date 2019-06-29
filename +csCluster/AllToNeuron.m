% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% a simple pass-through plugin
% where every detected spike is 
% assigned to the neuron that corresponds to the
% current nerve. no clustering is performed here
%
% this is expected to be useful in cases where the data is
% very clean and the spikes can be easily detected 

function self = AllToNeuron(self)



channel = self.channel_to_work_with;

spiketimes = (find(self.putative_spikes(:,channel)));

% if it's intracellular
temp = isstrprop(self.common.data_channel_names{channel},'upper');
if any(temp)

	% intracellular 
	neuron_name = self.common.data_channel_names{channel};
	self.spikes.(neuron_name).(neuron_name) = spiketimes;
else


	% extracellular 
	nerve_name = self.common.data_channel_names{channel};

	neuron_name = self.nerve2neuron.(nerve_name);
	if iscell(neuron_name)
		neuron_name = neuron_name{1};
	end

	self.spikes.(nerve_name).(neuron_name) = spiketimes;


end
