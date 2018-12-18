%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# NNgenerateTrainingData

**Syntax**

```
C.NNgenerateTrainingData()
```

**Description**

generates training data for a channel, assuming  that
there is some annotations on that channel 

%}
function [X, Y] = NNgenerateTrainingData(self)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end



% focus on the correct nerve
this_nerve = self.common.data_channel_names{self.channel_to_work_with};

% check that there are spikes on this channel
[s, s_by_unit] = self.getSpikesOnThisNerve;

channel = self.channel_to_work_with;

if isempty(channel)
	disp('No channel selected')
	return
end


self.updateSettingsFromAutomateInfo()


% create the training and test data

% create the +ve training data
self.putative_spikes(:,channel) = s;
self.getDataToReduce;
X = self.data_to_reduce;


if size(s_by_unit,2) > 1
	s_by_unit = s_by_unit(find(sum(s_by_unit')),:);
	[~,Y] = max(s_by_unit');

else
	% only one unit
	Y = zeros(1,length(X)) + max(nonzeros(s_by_unit));
end
Y = Y(:);


% now create some -ve training data
% halve the spike prominence and find spikes
new_spike_prom = self.common.automate_info(channel).spike_prom/2;
self.handles.spike_prom_slider.Max = new_spike_prom;
self.handles.spike_prom_slider.Value = new_spike_prom;

self.findSpikes(ceil(length(Y)/2)); % don't get in too much junk

% also pick some points at random, far from actual spikes so that we can augment the -ve training dataset
random_fake_spikes = find(circshift(s,floor(length(s)/3)));
dist_to_real_spikes = abs(random_fake_spikes - find(s));
too_close = dist_to_real_spikes < size(X,1)*2;
random_fake_spikes(too_close) = [];
if length(random_fake_spikes) >  size(X,2)/2
	random_fake_spikes = random_fake_spikes(1:floor(size(X,2)/2));
end
self.putative_spikes(random_fake_spikes,channel) = 1;

% remove the actual spikes
self.putative_spikes(logical(s),channel) = 0;

self.getDataToReduce;
X2 = self.data_to_reduce;

% we're going to label noise with 0
X = [X X2];
Y = [Y(:); zeros(size(X2,2),1)];

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
if ~isfield(self.common,'tf')
	self.common.tf.labels = {};
end
if isempty(self.common.tf.labels)
	self.common.tf.labels = {};
end
self.common.tf.labels{channel} = default_names;
