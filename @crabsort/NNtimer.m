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

try

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

% start parallel workers on all channels
if isempty(self.workers)
	for i = 1:self.n_channels
	    self.workers(i) = parfeval(gcp,@crabsort.NNtrainOnParallelWorker,0,[self.path_name 'network'],i);
	end
end

for i = 1:self.n_channels
	if length(self.workers) < i
		self.workers(i) = parfeval(gcp,@crabsort.NNtrainOnParallelWorker,0,[self.path_name 'network'],i);
	elseif strcmp(self.workers(i).State,'finished') || strcmp(self.workers(i).State,'unavailable')
		self.workers(i) = parfeval(gcp,@crabsort.NNtrainOnParallelWorker,0,[self.path_name 'network'],i);
	end
		
end


% at this point we can assume that workers are running


for i = 1:self.n_channels
	%disp(i)
	if isempty(self.common.NNdata(i).label_idx)
		continue
	end


	% figure out what the worker is doing

	D = strsplit(self.workers(i).Diary,'\n');


	if length(D) > 2 && strcmp(D{end-1},'No jobs, aborting...')
		% worker is idle
		self.handles.ax.NN_status(i).String = 'IDLE';

		if self.common.NNdata(i).isMoreTrainingNeeded
			% more training needed
			self.NNtrain(i);
		else
			% no more training needed
			self.destroyAllJobs(i);
		end

	else
		% training? 
		% update display
		

		if self.common.NNdata(i).isMoreTrainingNeeded
			self.handles.ax.NN_status(i).String = 'TRAINING';
			self.NNtrain(i);
		else
			self.handles.ax.NN_status(i).String = 'IDLE';
			self.destroyAllJobs(i);
		end

		[accuracy, timestamp_last_trained] = self.NNgetCurrentAccuracy(i);

		if ~isempty(accuracy)
			self.handles.ax.NN_accuracy(i).String = strlib.oval(str2double(accuracy),3);

			self.common.NNdata(i).timestamp_last_trained = timestamp_last_trained;
			self.common.NNdata(i).accuracy = str2double(accuracy);
		end
	end


end


catch err

	keyboard
end