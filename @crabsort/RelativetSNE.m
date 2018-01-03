% crabsort plugin
% plugin_type = 'dim-red';
% plugin_dimension = 2; 
% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% 
%
% this plugin implements t-SNE on an augmented
% data set that contains not just the full 
% spike shape but also timing information of 
% each spike relative to other, identified spikes
%
% Srinivas Gorur-Shandilya
% https://srinivas.gs/

function RelativetSNE(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% get the snippets 
V_snippets = self.getSnippets(self.channel_to_work_with);

% augment the data using time from all other sorted spikes
channels_with_spikes = false(length(self.data_channel_names),1);
fn = fieldnames(self.spikes);
for i = 1:length(self.data_channel_names)
	if any(strcmp(fn,self.data_channel_names{i}))
		channels_with_spikes(i) = true;
	end
end

relative_times = zeros(sum(channels_with_spikes)*2,size(V_snippets,2));

spiketimes = find(self.putative_spikes(:,self.channel_to_work_with));

idx = 0;

for i = 1:length(self.data_channel_names)
	if ~channels_with_spikes(i)
		continue
	end

	idx = idx + 1;

	% for each spike, find the time to the closest
	% spike in the past
	
	neuron_name = self.nerve2neuron.(self.data_channel_names{i});
	if iscell(neuron_name)
		neuron_name = neuron_name{1};
	end

	other_neuron_spiketimes = self.spikes.(self.data_channel_names{i}).(neuron_name);


	for j = 1:length(spiketimes)
		delta_spiketime = (spiketimes(j) - other_neuron_spiketimes);
		before = delta_spiketime(delta_spiketime > 0);
		after = delta_spiketime(delta_spiketime < 0);
		if isempty(before)
			relative_times((idx-1)*2 + 1,j) = 0;
		else
			relative_times((idx-1)*2 + 1,j) = min(abs(before));
		end

		if isempty(after)
			relative_times((idx-1)*2 + 2,j) = 0;
		else
			relative_times((idx-1)*2 + 2,j) = min(abs(after));
		end
	end
end

relative_times = relative_times/max(max(relative_times));

% interactively t-sne the data 
self.R{self.channel_to_work_with} = imctsne([V_snippets; relative_times]);