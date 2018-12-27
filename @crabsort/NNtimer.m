

function NNtimer(self,~,~)


for i = 1:self.n_channels
	if isempty(self.common.NNdata(i).label_idx)
		continue
	end

	if isempty(self.workers)
		% absolutely nothing, so let's train
		self.NNtrain(i);
	elseif length(self.workers) < i
		% no worker working on this channel, so let's train!
		self.NNtrain(i);
	elseif strcmp(self.workers(i).State,'finished')
		% retrain!
		self.NNtrain(i);
	elseif strcmp(self.workers(i).State,'running')
		% update display
		self.handles.ax.NN_status(i).String = 'TRAINING';


		D = self.workers(i).Diary;


		if length(D) < 5
			continue
		end

		D = strsplit(D,'\n');


		ValidationAccuracy = [];
		for j = length(D):-1:1
			if strcmp(strtrim(D{j}),'ValidationAccuracy=')
				ValidationAccuracy = strtrim(D{j+1});
				break
			end
		end

		if ~isempty(ValidationAccuracy)
			self.handles.ax.NN_accuracy(i).String = oval(str2double(ValidationAccuracy),3);
		end





	end


end



