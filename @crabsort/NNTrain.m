%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# NNtrain

**Syntax**

```
C.NNtrain(channel)
```

**Description**

Trains a neural network using labelled data on the current channel

this is a little shim function which offloads all its work
onto NNtrainOnParallelWorker()

%}

function NNtrain(self,channel)

assert(nargin == 2,'Need to specify the channel')

% check if there's automate data on this channel
if ~canDetectSpikes(self.common.NNdata(channel))
	return
end

% check if there's enough data to train on, with at least two
% categories
label_idx = self.common.NNdata(channel).label_idx;
if isempty(label_idx)
	return
end

if length(label_idx) < 10
	return
end

unique_labels = unique(label_idx);
if length(unique_labels) < 2
	return
end
for i = 1:length(unique_labels)
	if sum(label_idx == unique_labels(i)) < 10
		return
	end
end


self.NNmakeCheckpointDirs;

checkpoint_path = [self.path_name 'network' filesep self.common.data_channel_names{channel}];

% debug, run in foreground
%self.NNtrainOnParallelWorker(self.common.NNdata(channel),checkpoint_path)

self.workers(channel) = parfeval(gcp,@self.NNtrainOnParallelWorker,0,self.common.NNdata(channel),checkpoint_path);


