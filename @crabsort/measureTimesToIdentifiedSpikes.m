% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% measures the time from putative spikes on the current
% channel to identified spikes on other channels

function relative_times = measureTimesToIdentifiedSpikes(self,nerves,direction)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

assert(~isempty(nerves{1}),'nerves cannot be empty')

% augment the data using time from all other sorted spikes
channels_with_spikes = false(length(self.common.data_channel_names),1);
fn = fieldnames(self.spikes);
for i = 1:length(self.common.data_channel_names)
	if any(strcmp(fn,self.common.data_channel_names{i})) && any(strcmp(nerves,self.common.data_channel_names{i}))
		channels_with_spikes(i) = true;
	end
end

channels_with_spikes(self.channel_to_work_with) = false;

n_spikes = sum(self.putative_spikes(:,self.channel_to_work_with));


relative_times = zeros(sum(channels_with_spikes)*2,n_spikes);

spiketimes = find(self.putative_spikes(:,self.channel_to_work_with));

idx = 0;

for i = 1:length(self.common.data_channel_names)
	if ~channels_with_spikes(i)
		continue
	end

	idx = idx + 1;

	% for each spike, find the time to the closest
	% spike in the past and future
	
	neuron_name = self.nerve2neuron.(self.common.data_channel_names{i});
	if iscell(neuron_name)
		neuron_name = neuron_name{1};
	end

	other_neuron_spiketimes = self.spikes.(self.common.data_channel_names{i}).(neuron_name);


	for j = 1:length(spiketimes)
		delta_spiketime = (spiketimes(j) - other_neuron_spiketimes);
		before = delta_spiketime(delta_spiketime > 0);
		after = delta_spiketime(delta_spiketime < 0);
		if isempty(before)
			relative_times((idx-1)*2 + 1,j) = Inf;
		else
			relative_times((idx-1)*2 + 1,j) = min(abs(before));
		end

		if isempty(after)
			relative_times((idx-1)*2 + 2,j) = Inf;
		else
			relative_times((idx-1)*2 + 2,j) = min(abs(after));
		end
	end
end

switch direction
case 'past'
	relative_times = relative_times(1:2:end,:);
otherwise
	relative_times = relative_times(2:2:end,:);
end

cutoff = floor(1/self.dt);

max_value = max(relative_times(~isinf(relative_times)));

relative_times(relative_times > cutoff) = max_value;

try
	relative_times = relative_times/max_value;
catch
end