

function [accuracy, timestamp_last_trained] = NNgetCurrentAccuracy(self, worker)

D = self.workers(worker).Diary;

accuracy = [];
timestamp_last_trained = '';

if length(D) < 5
	return
end

D = strsplit(D,'\n');

accuracy = [];
for j = length(D)-1:-1:1
	if strcmp(strtrim(D{j}),'ValidationAccuracy=')
		accuracy = strtrim(D{j+1});
		break
	end
end

if isempty(accuracy)
	return
end

% read timestamp_last_trained of data training on
timestamp_last_trained = '';
for j = length(D)-1:-1:1
	if strcmp((D{j}),'timestamp of data training on = ')
		timestamp_last_trained = strtrim(D{j+1});
		break
	end
end