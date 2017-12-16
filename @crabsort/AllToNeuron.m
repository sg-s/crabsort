% crabsort plugin
% plugin_type = 'cluster';
% plugin_dimension = 2; 
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

function AllToNeuron(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

spiketimes = (find(self.putative_spikes(:,self.channel_to_work_with)));

nerve_name = self.handles.channel_label_chooser(self.channel_to_work_with).String;
nerve_name = nerve_name{self.handles.channel_label_chooser(self.channel_to_work_with).Value};

neuron_name = self.nerve2neuron.(nerve_name);

self.spikes.(nerve_name).(neuron_name) = spiketimes;