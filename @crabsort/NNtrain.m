%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# NNtrain

**Syntax**

```
C.NNtrain(channel, worker)
```

**Description**

Trains a neural network using labeled data on the current channel

this is a little shim function which offloads all its work
onto NNtrainOnParallelWorker()

%}

function NNtrain(self,channel)


arguments
	self (1,1) crabsort
	channel (1,1) double 
end

assert(nargin == 2,'Need to specify the channel')


NNdata = self.common.NNdata(channel);


% check if there's enough data to train on, with at least two
% categories
label_idx = NNdata.label_idx;
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

spikes_dir = fullfile(getpref('crabsort','store_spikes_here'),pathlib.lowestFolder(self.path_name));

checkpoint_path = fullfile(spikes_dir,'network', self.common.data_channel_names{channel});



% save all of this
% prioritize this file
focus_here = NNdata.file_idx == self.getFileSequence;
% if possible, get twice as many data_pts
N = sum(focus_here);
if N > length(focus_here)
	focus_here(:) = true;
elseif N < 10
	% pick most of the dataset
	focus_here(1:10:end) = true;
else
	S = ceil(length(focus_here)/N);
	focus_here(1:S:end) = true;
end



network_data.hash = NNdata.networkHash();
network_data.X =  NNdata.raw_data(:,focus_here);
network_data.Y = NNdata.label_idx(focus_here);
network_data.checkpoint_path = checkpoint_path;
network_data.timestamp = NNdata.timestamp_last_modified;


% train on parallel worker
self.futures(channel) = parfeval(@self.NNtrainOnParallelWorker,0,network_data);
