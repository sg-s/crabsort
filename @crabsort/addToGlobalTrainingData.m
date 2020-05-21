% this function adds the spikes in some channel
% to a global dataset that a global network can be trained on
% 
% usage:
% C.addToGlobalTrainingData() % where C is your crabsort object


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



% infer spike detection parameters
[spiketimes, Y] = self.getLabelledSpikes;
all_spiketimes = spiketimes;

if self.isIntracellular(self.channel_to_work_with)
	self.sdp.spike_sign = true;

else

	if mean(self.raw_data(spiketimes,self.channel_to_work_with)) < 0
		disp('Inferring negative spikes...')
		self.sdp.spike_sign = false;

	else
		disp('Inferring +ve spikes...')
		self.sdp.spike_sign = true;
	end

end



% set some standard parameters
self.sdp.t_before = 4;
self.sdp.t_after = 5;


% iteratively decrease spike prominence till we get all the spikes in the dataset
goon = true;
self.sdp.MinPeakProminence = mean(abs(self.raw_data(spiketimes,self.channel_to_work_with)));
disp('Estimating peak prominence...')
while goon
	self.findSpikes;
	if sum(self.putative_spikes(:,self.channel_to_work_with)) > length(spiketimes)
		goon = false;
	else
		self.sdp.MinPeakProminence = self.sdp.MinPeakProminence*.9;
	end


	disp(self.sdp.MinPeakProminence)
	

end








self.putative_spikes(:,channel) = 0;
self.putative_spikes(spiketimes,channel) = 1;
self.getDataToReduce;
X = self.data_to_reduce;


assert(length(Y) == size(X,2),'Size mismatch')


% --ve training data
self.putative_spikes(:,channel) = 0;

% now create some -ve training data
% halve the spike prominence and find spikes
self.sdp.MinPeakProminence = self.sdp.MinPeakProminence/2;
self.findSpikes(ceil(length(Y)/2)); % don't get in too much junk

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
if size(X2,2) > size(X,2)
	X2 = X2(:,1:size(X,2));
end
X = [X X2];

% normalize, if intracellular
if strcmp(upper(nerve_name),nerve_name)
	% intracellular
else
	% extracellular 
	y_scale = abs(self.handles.ax.ax(channel).YLim(1));
	for i = 1:size(X,2)
		X(:,i) = X(:,i)/y_scale;
	end
end

SpikeSign = self.sdp.spike_sign;

Y = [Y(:); categorical(repmat({'Noise'},size(X2,2),1))];
assert(length(Y) == size(X,2),'Size mismatch')


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
cats = categories(Y);
for i = 1:length(cats)
	subplot(1,length(cats),i); hold on

	mX = mean(X(:,Y == cats{i}),2);
	plot(mX)
	title(cats{i})

end
axlib.equalize


figlib.pretty()

disp(['Saving ' mat2str(length(Y)) ' new spikes...'])



% resample to a .1ms time step
old_time = linspace(-self.sdp.t_before,self.sdp.t_after,size(X,1));
new_time = linspace(-self.sdp.t_before,self.sdp.t_after,91);

new_X = NaN(91,size(X,2));
for i = 1:size(X,2)
	new_X(:,i) = interp1(old_time,X(:,i),new_time);
end

X = new_X;
clear new_X;



% save this 
filelib.mkdir([fileparts(fileparts(which('crabsort'))) filesep 'global-network'])


save([fileparts(fileparts(which('crabsort'))) filesep 'global-network' filesep nerve_name '_' mat2str(SpikeSign) '_' self.file_name '.mat'],'X','Y','SpikeSign')

self.chanel_stage(self.channel_to_work_with) = 3;