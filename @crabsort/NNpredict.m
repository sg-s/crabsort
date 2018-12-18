%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# NNpredict

**Syntax**

```
C.NNpredict()
```

**Description**

uses a trained Neural Network to make predictions and classify spikes

%}

function NNpredict(self,~,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end

channel = self.channel_to_work_with;

if isempty(channel)
	disp('No channel selected')
	return
end

% check if there's automate data on this channel
if ~self.doesChannelHaveAutomateInfo(channel)
	disp('there is no automate info, cannot predict')
	return
end


self.updateSettingsFromAutomateInfo()
new_spike_prom = self.common.automate_info(channel).spike_prom/2;
self.handles.spike_prom_slider.Max = new_spike_prom;
self.handles.spike_prom_slider.Value = new_spike_prom;

self.findSpikes;
self.getDataToReduce;
X = self.data_to_reduce;


network_loc = [self.path_name 'network' filesep self.common.data_channel_names{self.channel_to_work_with} filesep 'trained_network.mat'];

if exist(network_loc,'file') == 2
	load(network_loc,'trainedNet')
else
	disp('No network, cannot predict')
	return		
end

% predict 
SZ = size(X,1);
N = size(X,2);
X = reshape(X,SZ,1,1,N);


Y_pred = trainedNet.predict(X);
[~,Y_pred]=max(Y_pred,[],2);
Y_pred = Y_pred - 1;


nerve_name = self.common.data_channel_names{self.channel_to_work_with};
unit_names = self.nerve2neuron.(nerve_name);

putative_spikes = find(self.putative_spikes(:,self.channel_to_work_with));

assert(length(putative_spikes) == length(Y_pred),'Y_pred and putative spikes do not match')

for i = 1:length(unit_names)
	self.spikes.(nerve_name).(unit_names{i}) = putative_spikes(Y_pred==i);
end

self.putative_spikes(:,self.channel_to_work_with) = 0;
self.showSpikes;
