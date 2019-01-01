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

if ~self.auto_predict
	disp('auto_predict off, aborting')
	return
end
channel = self.channel_to_work_with;

if isempty(channel)
	return
end

NNdata = self.common.NNdata(channel);

if isempty(NNdata.other_nerves_control)
	disp('other_nerves_control empty, aborting')
	return
end


if isempty(NNdata.spike_prom)
	disp('spike_prom empty, aborting')
	return
end

if isempty(NNdata.spike_sign)
	disp('Spike sign empty, aborting')
	return
end


checkpoint_path = [self.path_name 'network' filesep self.common.data_channel_names{channel}];
H = NNdata.hash;
NN_dump_file = [checkpoint_path filesep H '.mat'];
if exist(NN_dump_file,'file') ~= 2
	disp('Cannot find network, aborting')
	return
end

self.updateSettingsFromNNdata()

self.findSpikes()

self.getDataToReduce()

X = self.data_to_reduce;

% load the net 
load(NN_dump_file,'trainedNet');
N = size(X,2);
SZ = size(X,1);
X = reshape(X,SZ,1,1,N);

Y_pred = predict(trainedNet,X);

[~,Y_pred] = max(Y_pred,[],2);
Y_pred = Y_pred - 1;

this_nerve = self.common.data_channel_names{channel};
unit_names =  self.nerve2neuron.(this_nerve);
if ~iscell(unit_names)
	unit_names = {unit_names};
end

putative_spikes = find(self.putative_spikes(:,channel));

for i = 1:length(unit_names)
	self.spikes.(this_nerve).(unit_names{i}) = putative_spikes(Y_pred==i);
end



self.channel_stage(self.channel_to_work_with) = 3;

enable(self.handles.manual_panel)

self.putative_spikes(:,channel) = 0;
self.showSpikes;