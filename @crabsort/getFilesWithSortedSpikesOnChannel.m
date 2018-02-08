% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%

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
   	if any(isstrprop(channel,'upper'))
   		% intracellular 
   		if length(spikes.(channel).(channel)) < 30
			continue
		end
   	else
		if length(spikes.(channel).(self.nerve2neuron.(channel))) < 30
			continue
		end
	end
	S = [S strrep(allfiles(i).name,'.crabsort','')];
end