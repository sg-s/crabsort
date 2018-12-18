

function NNtimer(self,~,~)

if isempty(self.channel_to_work_with)
	return
end

try
	D = self.workers(self.channel_to_work_with).Diary;
	D = strsplit(D,'\n');
catch
end



try
	ValidationAccuracy = [];
	for i = length(D):-1:1
		if strcmp(strtrim(D{i}),'ValidationAccuracy=')
			ValidationAccuracy = strtrim(D{i+1});
			break
		end
	end
	self.handles.nn_accuracy.String = ValidationAccuracy;
catch
end

try
	n_iter = [];
	for i = length(D):-1:1
		if strcmp(strtrim(D{i}),'iteration=')
			n_iter = strtrim(D{i+1});
			break
		end
	end
	self.handles.nn_iter.String = n_iter;
catch
end

