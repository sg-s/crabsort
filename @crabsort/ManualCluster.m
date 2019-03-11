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

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


% unpack
R = self.R{self.channel_to_work_with};
V_snippets = self.getSnippets(self.channel_to_work_with);


% temporary fix
disp('TEMP HOTFIX: showing data_to_reduce instead of V_snippets')
V_snippets = self.data_to_reduce;

channel = self.channel_to_work_with;
% if it's intracellular
temp = isstrprop(self.common.data_channel_names{channel},'upper');
if any(temp)

	% intracellular 
	default_neuron_name = self.common.data_channel_names{channel};
else
	default_neuron_name =  self.nerve2neuron.(self.common.data_channel_names{channel});
end

if iscell(default_neuron_name)
	default_names = [default_neuron_name, 'Noise'];
else
	default_names = {default_neuron_name, 'Noise'};
end



putative_spikes = find(self.putative_spikes(:,channel));
this_nerve = self.common.data_channel_names{channel};

[idx, labels] = clusterlib.manual(R,V_snippets,default_names,@self.showSpikeInContext);

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

for i = 1:length(self.handles.ax.data)
	try
	    self.handles.ax.ax(i).XLim = [0 5];
	    self.handles.ax.data(i).XData = self.time(a:z);
	    self.handles.ax.data(i).YData = self.raw_data(a:z,i);
	catch
	end
end
