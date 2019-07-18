% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% allows you to manually cluster a reduced-to-2D-dataset by 
% drawing lines around clusters. 
% 
function self = ManualCluster(self)


% unpack
R = self.R{self.channel_to_work_with};
V_snippets = self.getSnippets(self.channel_to_work_with);



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


M = clusterlib.manual('ReducedData',R','RawData',self.data_to_reduce,'labels',categorical(default_names),'AllowNewClasses',false); 
M.makeUI; 
M.MouseCallbackFcn = @self.showSpikeInContext;
uiwait(M.handles.main_fig)


idx = M.idx;
delete(M)

all_labels = categories(idx);

for i = 1:length(all_labels)
	if strcmp(all_labels{i},'Noise')
		continue
	end

	if strcmp(all_labels{i},'Undefined')
		continue
	end

	these_spikes = putative_spikes(idx==all_labels(i));

	self.spikes.(this_nerve).(all_labels{i}) = these_spikes;

end
