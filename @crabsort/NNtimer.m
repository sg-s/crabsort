

function NNtimer(self,~,~)

if isempty(self.channel_to_work_with)
	return
end


% can we spin up a worker? 
this_nerve = self.common.data_channel_names{self.channel_to_work_with};

if isfield(self.spikes,this_nerve)
	if isempty(self.workers)
		% empty workers, have spikes, so let's train!
		self.NNtrain;
		return
	else
		if length(self.workers) < self.channel_to_work_with
			self.NNtrain;
			return
		else
			if isvalid(self.workers(self.channel_to_work_with))

				% valid worker
				if strcmp(self.workers(self.channel_to_work_with).State,'finished')
					% retrain!
					self.NNtrain;
					return
				elseif strcmp(self.workers(self.channel_to_work_with).State,'running')
				end

			else
				% invalid object
				% retrain!
				self.NNtrain;
				return

			end
		end
	end
end


if isempty(self.workers)
	self.handles.nn_status.String = 'NO NET';
	return
end


try
	D = self.workers(self.channel_to_work_with).Diary;
	D = strsplit(D,'\n');
catch
	return
end


try
	ValidationAccuracy = [];
	for i = length(D):-1:1
		if strcmp(strtrim(D{i}),'ValidationAccuracy=')
			ValidationAccuracy = strtrim(D{i+1});
			break
		end
	end
	if ~isempty(ValidationAccuracy)
		self.handles.nn_accuracy.String = oval(str2double(ValidationAccuracy),3);
	end
catch
end


if strcmp(self.workers(self.channel_to_work_with).State,'finished')
	self.handles.nn_status.String = 'IDLE';
elseif strcmp(self.workers(self.channel_to_work_with).State,'running')
	self.handles.nn_status.String = 'TRAINING';
elseif ~isempty(self.workers.Error)
	self.handles.nn_status.String = 'ERROR';
end

