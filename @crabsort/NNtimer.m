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

for i = 1:self.n_channels
	%disp(i)
	if isempty(self.common.NNdata(i).label_idx)
		continue
	end

	if isempty(self.workers)
		% absolutely nothing, so let's train
		if self.common.NNdata(i).isMoreTrainingNeeded
			self.NNtrain(i);
		else
			% no more training needed
			self.handles.ax.NN_status(i).String = 'IDLE';
			self.handles.ax.NN_accuracy(i).String = strlib.oval(self.common.NNdata(i).accuracy,3);
			if self.channel_stage(i) == 0 && ~isempty(self.channel_to_work_with) && self.channel_to_work_with == i
				% let's make some predictions
				self.NNpredict;
			end
		end
	elseif length(self.workers) < i
		% no worker working on this channel, so let's train!
		if self.common.NNdata(i).isMoreTrainingNeeded
			self.NNtrain(i);
		else
			self.handles.ax.NN_status(i).String = 'IDLE';
			self.handles.ax.NN_accuracy(i).String = strlib.oval(self.common.NNdata(i).accuracy,3);
			if self.channel_stage(i) == 0 && ~isempty(self.channel_to_work_with) && self.channel_to_work_with == i
				% let's make some predictions
				self.NNpredict;
			end
		end
	elseif strcmp(self.workers(i).State,'finished') || strcmp(self.workers(i).State,'unavailable')
		% retrain!
		%disp('worker finished or unavailable')
		if self.common.NNdata(i).isMoreTrainingNeeded
			self.NNtrain(i);
		else
			self.handles.ax.NN_status(i).String = 'IDLE';
			self.handles.ax.NN_accuracy(i).String = strlib.oval(self.common.NNdata(i).accuracy,3);

			if self.channel_stage(i) == 0 && ~isempty(self.channel_to_work_with) && self.channel_to_work_with == i
				% let's make some predictions
				self.NNpredict;
			end
		end
	elseif strcmp(self.workers(i).State,'running')
		% update display
		self.handles.ax.NN_status(i).String = 'TRAINING';

		[accuracy, hash] = self.NNgetCurrentAccuracy(i);


		if ~isempty(accuracy)
			self.handles.ax.NN_accuracy(i).String = strlib.oval(str2double(accuracy),3);

			self.common.NNdata(i).accuracy_hash = hash;
			self.common.NNdata(i).accuracy = str2double(accuracy);
		end


	end


end



