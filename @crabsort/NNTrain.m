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

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end



% check if there's automate data on this channel
if ~isvalid(self.common.NNdata(channel))
	disp('there is no automate info, cannot train')
	return
end


% gather the training data and test data
H =  self.common.NNdata(channel).hash();

if strcmp(H,'00000000000000000000000000000000')
    disp('Missing info, cannot train')
    return
end

self.NNmakeCheckpointDirs;

checkpoint_path = [self.path_name 'network' filesep self.common.data_channel_names{channel}];

% debug, run in foreground
% self.NNtrainOnParallelWorker(self.common.NNdata(channel),checkpoint_path)

self.workers(channel) = parfeval(gcp,@self.NNtrainOnParallelWorker,0,self.common.NNdata(channel),checkpoint_path);


