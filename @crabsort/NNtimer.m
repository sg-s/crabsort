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



spinner_symbols = {'.','..','...','+'};




for i = 1:self.n_channels

	% backwards compatibility
	if isempty(self.common.NNdata(i).accuracy)
		self.common.NNdata(i).accuracy = 0;
	end


	if isempty(self.common.NNdata(i).label_idx)
		continue
	end

	if ~isempty(self.common.NNdata(i).accuracy)
		self.handles.ax.NN_accuracy(i).String = mat2str(self.common.NNdata(i).accuracy,3);
	end


	switch self.futures(i).State

	case 'unavailable'

		% nothing ever has run

		if self.common.NNdata(i).isMoreTrainingNeeded

			spinner = spinner_symbols{randi(4)};
			self.handles.ax.NN_status(i).String = ['TRAINING' spinner];
			self.NNtrain(i);
		else
			self.handles.ax.NN_status(i).String = 'IDLE';	

		end



	case 'finished'

		[self.common.NNdata(i).accuracy, self.common.NNdata(i).timestamp_last_trained] = self.NNgetCurrentAccuracy(i);

		self.handles.ax.NN_accuracy(i).String = mat2str(self.common.NNdata(i).accuracy,3);

		if self.common.NNdata(i).isMoreTrainingNeeded
			
			spinner = spinner_symbols{randi(4)};
			self.handles.ax.NN_status(i).String = ['TRAINING' spinner];

			self.NNtrain(i);

		else
			self.handles.ax.NN_status(i).String = 'IDLE';
		end

		

	case 'running'
		[self.common.NNdata(i).accuracy, self.common.NNdata(i).timestamp_last_trained] = self.NNgetCurrentAccuracy(i);

		self.handles.ax.NN_accuracy(i).String = mat2str(self.common.NNdata(i).accuracy,3);

		spinner = spinner_symbols{randi(4)};
		self.handles.ax.NN_status(i).String = ['TRAINING' spinner];

	end

end

