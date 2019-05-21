%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# NNtimer

**Syntax**

```
C.NNtimer(~,~)
```

**Description**

this function is meant to be run on a timer
it does the following things:

1. update the accuracy displays on every channel
2. trains a network if it needs to be

%}


function NNtimer(self,~,~)



if isempty(self.handles)
	return

end

if ~isfield(self.handles,'ax')
	return
end

if isempty(self.handles.ax)
	return
end

if self.automate_action ~= crabsort.automateAction.none
	return
end

% clear old messages if need be
if (now - self.handles.main_fig.UserData)*86400 > 5
	self.handles.main_fig.Name = [self.file_name];
end

% make sure there is a worker running on everything
if isempty(self.n_channels) || self.n_channels == 0 
	return
end

% start as many parallel workers as possible
if isempty(self.workers)
	for i = 1:self.NumWorkers
	    self.workers(i) = parfeval(gcp,@crabsort.NNtrainOnParallelWorker,0,[self.path_name 'network'],i);
	end
end

for i = 1:self.NumWorkers
	if length(self.workers) < i
		self.workers(i) = parfeval(gcp,@crabsort.NNtrainOnParallelWorker,0,[self.path_name 'network'],i);
	elseif strcmp(self.workers(i).State,'finished') || strcmp(self.workers(i).State,'unavailable')
		self.workers(i) = parfeval(gcp,@crabsort.NNtrainOnParallelWorker,0,[self.path_name 'network'],i);
	end
		
end


% at this point we can assume that workers are running


% figure out which workers are idle and ready to receive jobs
free_workers = [];
for i = 1:self.NumWorkers
	D = strsplit(self.workers(i).Diary,'\n');
	if length(D) > 2 && strcmp(D{end-1},'No jobs, aborting...')
		free_workers = [free_workers; i];
	end

end



for i = 1:self.n_channels

	if isempty(self.common.NNdata(i).label_idx)
		continue
	end

	if ~isempty(self.common.NNdata(i).accuracy)
		self.handles.ax.NN_accuracy(i).String = strlib.oval(self.common.NNdata(i).accuracy,3);
	end


	if ~isnan(self.training_on(i))
		D = strsplit(self.workers(self.training_on(i)).Diary,'\n');
	else
		D = {};
	end


	if length(D) > 2 && strcmp(D{end-1},'No jobs, aborting...')
		% worker is idle
		self.training_on(i) = NaN;
		self.handles.ax.NN_status(i).String = 'IDLE';

	elseif length(D) > 2
		% actively training? update display
		self.handles.ax.NN_status(i).String = 'TRAINING';
		[accuracy, timestamp_last_trained] = self.NNgetCurrentAccuracy(self.training_on(i));

		if ~isempty(accuracy)
			self.handles.ax.NN_accuracy(i).String = strlib.oval(str2double(accuracy),3);

			self.common.NNdata(i).timestamp_last_trained = timestamp_last_trained;
			self.common.NNdata(i).accuracy = str2double(accuracy);
		end

	end


	if self.common.NNdata(i).isMoreTrainingNeeded
		% more training needed
		self.handles.ax.NN_status(i).String = 'TRAINING';
		if isnan(self.training_on(i))
			train_on_this = free_workers(1);
			free_workers(1) = [];
			self.training_on(i) = train_on_this;
		end
		
		self.NNtrain(i, self.training_on(i));

	else
		% no more training needed
		self.destroyAllJobs();

	end








	% checkpoint_path = [self.path_name 'network' filesep self.common.data_channel_names{i}];

	% H = self.common.NNdata(i).networkHash();
	% NN_dump_file = [checkpoint_path filesep H '.mat'];






end

