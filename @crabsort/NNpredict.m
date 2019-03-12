%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# NNpredict

**Syntax**

```
NNpredict(self, channel)
```

**Description**

makes predictions using a trained neural network

%}

function NNpredict(self, futz_factor)

if nargin == 1
	futz_factor = .5;
end

if ~self.auto_predict && self.automate_action == crabsort.automateAction.none
	return
end
channel = self.channel_to_work_with;

if isempty(channel)
	return
end

NNdata = self.common.NNdata(channel);

if ~NNdata.canDetectSpikes()
	return
end


checkpoint_path = [self.path_name 'network' filesep self.common.data_channel_names{channel}];

H = NNdata.networkHash();


NN_dump_file = [checkpoint_path filesep H '.mat'];
if exist(NN_dump_file,'file') ~= 2
	self.say('Cannot find network, aborting')
	return
end



self.NNsync(futz_factor)

self.findSpikes()
spiketimes = find(self.putative_spikes(:,channel));

n_spikes = sum(spiketimes);

if n_spikes == 0
	self.say('No spikes detected, nothing to do.')
	self.channel_stage(channel) = 3;
	return
else
	self.say([strlib.oval(n_spikes) ' spikes detected; using NN to sort...'])
end

self.getDataToReduce()

X = self.data_to_reduce;

% load the net 
load(NN_dump_file,'trainedNet');
N = size(X,2);
SZ = size(X,1);
X = reshape(X,SZ,1,1,N);


[Y_pred, scores] = classify(trainedNet,X);


uncertain_spikes = (max(scores,[],2) - 1./size(scores,2)).*size(scores,2)<1;




this_nerve = self.common.data_channel_names{channel};

putative_spikes = find(self.putative_spikes(:,channel));
uncertain_spikes = putative_spikes(uncertain_spikes);


% overwrite any predictions from the NN using manual annotations
% stored in NNdata
manual_labels = NNdata.label_idx(NNdata.file_idx == self.getFileSequence);
uniq_manual_labels = unique(NNdata.label_idx);


if any(NNdata.file_idx == self.getFileSequence)
	manually_labelled_spikes = NNdata.spiketimes(NNdata.file_idx == self.getFileSequence);



	uncertain_spikes = setdiff(uncertain_spikes,manually_labelled_spikes);

	if ~isempty(manual_labels)
		


		for i = 1:length(uniq_manual_labels)
			mark_as_spike = ismember(putative_spikes,manually_labelled_spikes(manual_labels==uniq_manual_labels(i)));
			Y_pred(mark_as_spike) = uniq_manual_labels(i);
		end
	end
end

% store in spikes
for i = 1:length(uniq_manual_labels)
	if strcmp(char(uniq_manual_labels(i)),'Noise')
		continue
	end
	self.spikes.(this_nerve).(char(uniq_manual_labels(i))) = spiketimes(Y_pred == uniq_manual_labels(i));
end


% show the uncertain spikes
self.handles.ax.uncertain_spikes(channel).XData = uncertain_spikes*self.dt;
yrange = diff(self.handles.ax.ax(channel).YLim);

if self.sdp.spike_sign
	self.handles.ax.uncertain_spikes(channel).YData = self.raw_data(uncertain_spikes,channel)+yrange*.07;
	self.handles.ax.uncertain_spikes(channel).Marker = 'v';
else
	self.handles.ax.uncertain_spikes(channel).YData = self.raw_data(uncertain_spikes,channel)-yrange*.07;
	self.handles.ax.uncertain_spikes(channel).Marker = '^';
end







self.channel_stage(channel) = 3;

uxlib.enable(self.handles.manual_panel)

self.putative_spikes(:,channel) = 0;
self.showSpikes;

self.say('DONE. Spikes classified using NN')

