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

function NNpredict(self)

% if ~self.auto_predict && self.automate_action == crabsort.automateAction.none
% 	return
% end
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
	%disp('Cannot find network, aborting')
	return
end



self.NNsync(.5)

self.findSpikes()

n_spikes = sum(self.putative_spikes(:,channel));

if n_spikes == 0
	self.say('No spikes detected, nothing to do.')
else
	self.say([oval(n_spikes) ' spikes detected; using NN to sort...'])
end

self.getDataToReduce()

X = self.data_to_reduce;

% load the net 
load(NN_dump_file,'trainedNet');
N = size(X,2);
SZ = size(X,1);
X = reshape(X,SZ,1,1,N);

Y_pred = predict(trainedNet,X);

prediction_confidence = (max(Y_pred,[],2) -  min(Y_pred,[],2));

uncertain_spikes = (prediction_confidence<.2);

[~,Y_pred] = max(Y_pred,[],2);
Y_pred = Y_pred - 1;

this_nerve = self.common.data_channel_names{channel};
unit_names =  self.nerve2neuron.(this_nerve);
if ~iscell(unit_names)
	unit_names = {unit_names};
end

putative_spikes = find(self.putative_spikes(:,channel));

uncertain_spikes = putative_spikes(uncertain_spikes);
self.handles.ax.uncertain_spikes(channel).XData = uncertain_spikes*self.dt;
yrange = diff(self.handles.ax.ax(channel).YLim);

if self.sdp.spike_sign
	self.handles.ax.uncertain_spikes(channel).YData = self.raw_data(uncertain_spikes,channel)+yrange*.07;
	self.handles.ax.uncertain_spikes(channel).Marker = 'v';
else
	self.handles.ax.uncertain_spikes(channel).YData = self.raw_data(uncertain_spikes,channel)-yrange*.07;
	self.handles.ax.uncertain_spikes(channel).Marker = '^';
end

for i = 1:length(unit_names)
	self.spikes.(this_nerve).(unit_names{i}) = putative_spikes(Y_pred==i);
end



self.channel_stage(channel) = 3;

mtools.ux.enable(self.handles.manual_panel)

self.putative_spikes(:,channel) = 0;
self.showSpikes;

self.say('DONE. Spikes classified using NN')

