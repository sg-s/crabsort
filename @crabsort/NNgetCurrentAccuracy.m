

function [accuracy, timestamp_last_trained] = NNgetCurrentAccuracy(self, worker)

arguments
	self (1,1) crabsort
	worker (1,1) double

end

if self.verbosity > 9
	disp(mfilename)
end



D = self.futures(worker).Diary;

accuracy = 0;
timestamp_last_trained = '';

if length(D) < 5
	return
end

D = strsplit(D,'\n');

accuracy = [];
for j = length(D)-1:-1:1
	if strcmp(strtrim(D{j}),'ValidationAccuracy=')
		accuracy = str2double(strtrim(D{j+1}));
		break
	end
end

if isempty(accuracy)
	accuracy = 0;
	return
end

% read timestamp_last_trained of data training on
for j = length(D)-1:-1:1
	if strcmp((D{j}),'timestamp of data training on = ')
		timestamp_last_trained = strtrim(D{j+1});
		break
	end
end
