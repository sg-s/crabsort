function addToGlobalTrainingData(self, nerve_name)



if isempty(self.channel_to_work_with)
	return
else
	channel = self.channel_to_work_with;
end

if isempty(channel)
	self.say('No channel selected, aborting!')
	return
end


if nargin == 1
	nerve_name = self.common.data_channel_names{channel};
end


self.say('Generating training data for NN...')

[spiketimes, Y] = self.getLabelledSpikes;
all_spiketimes = spiketimes;


self.putative_spikes(:,channel) = 0;
self.putative_spikes(spiketimes,channel) = 1;
self.getDataToReduce;
X = self.data_to_reduce;


assert(length(Y) == size(X,2),'Size mismatch')




% also pick some points at random, far from actual spikes so that we can augment the -ve training dataset
random_fake_spikes = veclib.shuffle(find(self.mask(:,channel)));
random_fake_spikes = random_fake_spikes(1:length(spiketimes));

dist_to_real_spikes = NaN*random_fake_spikes;
for i = 1:length(dist_to_real_spikes)
	dist_to_real_spikes(i) = min(abs(random_fake_spikes(i)-spiketimes));
end

too_close = dist_to_real_spikes < 2*size(X,1);
random_fake_spikes(too_close) = [];

% don't include too many
if length(random_fake_spikes) > length(Y)/2
	random_fake_spikes = random_fake_spikes(ceil(1:length(Y)/2));
end

if ~isempty(random_fake_spikes)
	self.putative_spikes(random_fake_spikes,channel) = 1;
end

% remove the actual spikes
self.putative_spikes(spiketimes,channel) = 0;

self.getDataToReduce;
all_spiketimes = [all_spiketimes(:); find(self.putative_spikes(:,channel))];
X2 = self.data_to_reduce;

% reset
self.putative_spikes(:,channel) = 0;

% we're going to label noise as "Noise"
X = [X X2];


Y = [Y(:); categorical(repmat({'Noise'},size(X2,2),1))];
assert(length(Y) == size(X,2),'Size mismatch')

disp(['Saving ' mat2str(length(Y)) ' new spikes...'])

% save this 
filelib.mkdir([fileparts(fileparts(which('crabsort'))) filesep 'global-network'])


save([fileparts(fileparts(which('crabsort'))) filesep 'global-network' filesep nerve_name '_' self.file_name '.mat'],'X','Y')