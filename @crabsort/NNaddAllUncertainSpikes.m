function NNaddAllUncertainSpikes(self, ~, ~)

channel = self.channel_to_work_with;

% find closest identified point 
[spiketimes, labels] = self.getLabelledSpikes;

uncertain_spikes = round(self.handles.ax.uncertain_spikes(channel).XData/self.dt);


if isempty(uncertain_spikes) || any(isnan(uncertain_spikes))
	self.say('No uncertain spikes')
	beep
	return

end

add_these_spikes = spiketimes(ismember(spiketimes,uncertain_spikes));
add_these_labels = labels(ismember(spiketimes,uncertain_spikes));


% now use the NN to make predictions so we can figure out which 
% spikes the NN got wrong
self.NNpredict()


% find closest identified point 
[~, labels_NN] = self.getLabelledSpikes;

add_these = (labels ~= labels_NN);

add_these_spikes = ([add_these_spikes; spiketimes(add_these)]);
add_these_labels = ([add_these_labels; labels(add_these)]);

[add_these_spikes, idx] = unique(add_these_spikes);
add_these_labels = add_these_labels(idx);

self.loadSDPFromNNdata()



self.putative_spikes(:,channel) = 0;
self.putative_spikes(add_these_spikes,channel) = 1;
self.getDataToReduce;
X = self.data_to_reduce;


% now append it to NNdata as needed
NNdata = self.common.NNdata(channel);




% some data already exists
% nuke all previous data with the same sequence 
rm_this = NNdata.file_idx == self.getFileSequence & ismember(NNdata.spiketimes,add_these_spikes);
NNdata.raw_data(:,rm_this) = [];
NNdata.label_idx(rm_this) = [];
NNdata.spiketimes(rm_this) = [];
NNdata.file_idx(rm_this) = [];
NNdata.check()

% append new data
NNdata.raw_data = [NNdata.raw_data X];
NNdata.label_idx = [NNdata.label_idx; add_these_labels(:)];
NNdata.spiketimes = [NNdata.spiketimes; add_these_spikes(:)];
NNdata.file_idx = [NNdata.file_idx; 0*add_these_spikes(:) + self.getFileSequence];
NNdata.check()



self.common.NNdata(channel) = NNdata;


self.NNpredict();

self.say(['Added ' strlib.oval(length(add_these_spikes)) ' spikes to training data'])