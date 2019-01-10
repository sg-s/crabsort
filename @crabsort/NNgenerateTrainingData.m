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
there is some annotations on that channel. this is typically
called after clustering occurs, and will generate
+ve and -ve training data from this channel

%}
function NNgenerateTrainingData(self)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


if isempty(self.channel_to_work_with)
	return
else
	channel = self.channel_to_work_with;
end

self.say('Generating training data for NN...')

% focus on the correct nerve
this_nerve = self.common.data_channel_names{channel};

% check that there are spikes on this channel
[s, s_by_unit] = self.getSpikesOnThisNerve;


if isempty(channel)
	disp('No channel selected')
	return
end


self.NNsync()


% create the training and test data

% create the +ve training data
self.putative_spikes(:,channel) = s;
self.getDataToReduce;
all_spiketimes = find(self.putative_spikes(:,channel));
X = self.data_to_reduce;


if size(s_by_unit,2) > 1
	s_by_unit = s_by_unit(find(sum(s_by_unit')),:);
	[~,Y] = max(s_by_unit');

else
	% only one unit
	Y = zeros(size(X,2),1) + max(nonzeros(s_by_unit));
end
Y = Y(:);
assert(length(Y) == size(X,2),'Size mismatch')


% now create some -ve training data
% halve the spike prominence and find spikes
self.NNsync(.5);

self.findSpikes(ceil(length(Y)/2)); % don't get in too much junk

% also pick some points at random, far from actual spikes so that we can augment the -ve training dataset
random_fake_spikes = shuffle(find(self.mask(:,channel)));
random_fake_spikes = random_fake_spikes(1:sum(s));

dist_to_real_spikes = min(pdist2(random_fake_spikes,find(s)));

too_close = dist_to_real_spikes < size(X,1);
random_fake_spikes(too_close) = [];
if ~isempty(random_fake_spikes)
	self.putative_spikes(random_fake_spikes,channel) = 1;
end

% remove the actual spikes
self.putative_spikes(logical(s),channel) = 0;

self.getDataToReduce;
all_spiketimes = [all_spiketimes(:); find(self.putative_spikes(:,channel))];
X2 = self.data_to_reduce;

self.putative_spikes(:,channel) = 0;

% we're going to label noise with 0
X = [X X2];
Y = [Y(:); zeros(size(X2,2),1)];
assert(length(Y) == size(X,2),'Size mismatch')

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

% now append it to NNdata as needed
NNdata = self.common.NNdata(channel);

if isempty(NNdata.raw_data)


	NNdata.raw_data = X;
	NNdata.label_idx = Y(:);
	NNdata.spiketimes =  all_spiketimes(:);
	NNdata.file_idx = 0*all_spiketimes(:) + self.getFileSequence;
	NNdata.check()

else
	% some data already exists
	% nuke all previous data with the same sequence 
	rm_this = NNdata.file_idx == self.getFileSequence;
	NNdata.raw_data(:,rm_this) = [];
	NNdata.label_idx(rm_this) = [];
	NNdata.spiketimes(rm_this) = [];
	NNdata.file_idx(rm_this) = [];
	NNdata.check()

	% append new data
	NNdata.raw_data = [NNdata.raw_data X];
	NNdata.label_idx = [NNdata.label_idx; Y(:)];
	NNdata.spiketimes = [NNdata.spiketimes; all_spiketimes(:)];
	NNdata.file_idx = [NNdata.file_idx; 0*all_spiketimes(:) + self.getFileSequence];
	NNdata.check()
end

self.common.NNdata(channel) = NNdata;