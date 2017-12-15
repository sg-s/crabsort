% crabsort plugin
% plugin_type = 'dim-red';
% plugin_dimension = 1; 
% 
% this is a plugin for crabsort.m
% this plugin does nothing -- just passes all data through
% useful for cases where the signal is very clean
% and you want every putative spike to be assigned to 
% a single neuron 

function Pass(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

n_spikes = sum(self.putative_spikes(:,self.channel_to_work_with));
self.R{self.channel_to_work_with} = zeros(n_spikes,2);