%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# NNTrain

**Syntax**

```
C.train()
```

**Description**

Trains a neural network using labelled data on the current channel

%}

function NNTrain(self,~,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end

if isempty(self.channel_to_work_with)
	disp('No channel selected')
	return
end

% check if there's automate data on this channel
if ~self.doesChannelHaveAutomateInfo(self.channel_to_work_with)
	disp('there is no automate info, cannot train')
	return
end


% gather the training data and test data
training_data = self.NNgenerateTrainingData;

% train on a parallel worker 

