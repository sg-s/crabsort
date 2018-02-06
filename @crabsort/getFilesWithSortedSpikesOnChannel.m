function S = getFilesWithSortedSpikesOnChannel(self,channel)

% get all crabsort data for this channel
[~,~,ext] = fileparts(joinPath(self.path_name,self.file_name));
allfiles = dir([self.path_name '*' ext '.crabsort']);


S = {};
for i = 1:length(allfiles)
	clear spikes
	load(joinPath(allfiles(i).folder, allfiles(i).name),'-mat')
	spikes = crabsort_obj.spikes;
	if isempty(spikes)
		continue
	end
	if ~isfield(spikes,channel)
		continue
	end
	if length(spikes.(channel).(self.nerve2neuron.(channel))) < 30
		continue
	end
	S = [S strrep(allfiles(i).name,'.crabsort','')];
end