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
% allows you to manually cluster a reduced-to-2D-dataset by drawling lines around clusters
% 
function ManualCluster(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% unpack
R = self.R{self.channel_to_work_with};
V_snippets = self.getSnippets(self.channel_to_work_with);

default_neuron_name =  self.nerve2neuron.(self.data_channel_names{self.channel_to_work_with});
default_names = {default_neuron_name, 'Noise'};

[idx, labels] = manualCluster(R,V_snippets,default_names,@self.showSpikeInContext);


putative_spikes = find(self.putative_spikes(:,self.channel_to_work_with));
this_nerve = self.data_channel_names{self.channel_to_work_with};


for i = 1:length(labels)
	if strcmp(labels{i},'Noise')
		continue
	end

	these_spikes = putative_spikes(idx==i);

	self.spikes.(this_nerve).(labels{i}) = these_spikes;

end

% update the X and Y data since we don't want to show everything
a = find(self.time >= 0, 1, 'first');
z = find(self.time <= 5, 1, 'last');

for i = 1:length(self.handles.data)
    self.handles.ax(i).XLim = xlim;
    self.handles.data(i).XData = self.time(a:z);
    self.handles.data(i).YData = self.raw_data(a:z,i);
end