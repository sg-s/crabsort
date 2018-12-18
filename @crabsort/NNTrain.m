%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# NNtrain

**Syntax**

```
C.train()
```

**Description**

Trains a neural network using labelled data on the current channel

%}

function NNtrain(self,~,~)

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
[X, Y] = self.NNgenerateTrainingData;

% split into training and validation
R = rand(size(X,2),1)>.5;


X_train = X(:,R);
Y_train = Y(R);

X_validate = X(:,~R);
Y_validate = Y(~R);


% make layers for the neural net
SZ = size(X_train,1);


% is there a previously saved network? 
self.NNmakeCheckpointDirs;

checkpoint_path = [self.path_name 'network' filesep self.common.data_channel_names{self.channel_to_work_with}];


saved_files = dir([checkpoint_path filesep '*.mat']);


if length(saved_files) == 0
    disp('Making new network...')
	layers = self.NNmake(SZ,length(unique(Y_train)));
else

	% load
	net = self.NNload();
    layers = net.Layers;
end


N_train = size(X_train,2);
N_validate = size(X_validate,2);
X_train = reshape(X_train,SZ,1,1,N_train);
X_validate = reshape(X_validate,SZ,1,1,N_validate);

Y_train = categorical(Y_train(:));
Y_validate = categorical(Y_validate(:));

options = trainingOptions('sgdm',...
    'LearnRateSchedule','piecewise',...
    'Shuffle','every-epoch',...
    'LearnRateDropFactor',0.2,...
    'LearnRateDropPeriod',10,...
    'MaxEpochs',30,...
    'MiniBatchSize',32,...
    'ValidationData',{X_validate, Y_validate},...
    'ValidationFrequency',5,...
    'Plots','none',...
    'Verbose',0,...
    'CheckpointPath',checkpoint_path,...
    'ExecutionEnvironment','cpu',...
    'OutputFcn',@self.NNshowResult);


% self.workers(self.channel_to_work_with) = parfeval(gcp,@self.NNtrainAndSave,0,X_train,Y_train,layers,options);


self.NNtrainAndSave(X_train,Y_train,layers,options);

% debug, save validation data
save('validation_data.mat','X_validate','Y_validate')
