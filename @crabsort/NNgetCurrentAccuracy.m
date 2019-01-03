

function [accuracy, hash] = NNgetCurrentAccuracy(self, channel)

D = self.workers(channel).Diary;

accuracy = [];
hash = '';

if length(D) < 5
	return
end

D = strsplit(D,'\n');

accuracy = [];
for j = length(D):-1:1
	if strcmp(strtrim(D{j}),'ValidationAccuracy=')
		accuracy = strtrim(D{j+1});
		break
	end
end

if isempty(accuracy)
	return
end


% read hash of data training on
hash = '';
for j = length(D)-1:-1:1
	if strcmp(strtrim(D{j}),'hash of data training on =')
		hash = strtrim(D{j+1});
		break
	end
end