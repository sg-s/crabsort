% deletes spikes of a nerve that are probably artifacts
% of another neuron on another nerve
% example
% 
% crabsort.pruneSpikes('828_114_2','lvn','lgn/LG')
function pruneSpikes(self, based_on, tolerance)


arguments
	self (1,1) crabsort
	based_on char
	tolerance (1,1) double = 5e-4
end

disp('pruning spikes...')


assert(~isempty(strfind(based_on,'/')),'based_on not formatted correctly')


delete_from_this_nerve = self.common.data_channel_names{self.channel_to_work_with};

fprintf(['Estimating offset between spikes on ' delete_from_this_nerve ' and ' based_on '\n'])

based_on = strsplit(based_on,'/');
based_on_nerve = based_on{1};
based_on_neuron = based_on{2};


% first determine the offset

spikes =  self.spikes;

if ~isfield(spikes,delete_from_this_nerve)
	return
end

if ~isfield(spikes,based_on_nerve)
	return
end

if ~isfield(spikes.(based_on_nerve),based_on_neuron)
	return
end

trigger_pts = spikes.(based_on_nerve).(based_on_neuron);

if isempty(trigger_pts)
	return
end

fn = fieldnames(spikes.(delete_from_this_nerve));
all_spikes = [];
for j = 1:length(fn)
	all_spikes = [all_spikes; spikes.(delete_from_this_nerve).(fn{j})];
end


min_dist = min(pdist2(trigger_pts,all_spikes),[],2);

min_dist(min_dist > tolerance*2/self.dt) = [];
if isempty(min_dist)
	return
end
offset = mode(min_dist);

disp('Offset is: ')
disp(offset)



% correct trigger pts by the offset
if length(intersect(trigger_pts-offset,all_spikes)) > length(intersect(trigger_pts+offset,all_spikes))
trigger_pts = trigger_pts - offset;
else
trigger_pts = trigger_pts + offset;
end


delete_these_spikes = all_spikes((min(pdist2(all_spikes,trigger_pts),[],2))  < round(tolerance/self.dt));

if isempty(delete_these_spikes)
	return
end




% now delete these spikes
for j = 1:length(fn)
	spikes.(delete_from_this_nerve).(fn{j}) = setdiff(spikes.(delete_from_this_nerve).(fn{j}),delete_these_spikes);
end




disp(['deleting ' mat2str(length(delete_these_spikes)) ' spikes'])

self.spikes = spikes;


% remove uncertain spike markers
channel = self.channel_to_work_with;
uncertain_spikes = round(self.handles.ax.uncertain_spikes(channel).XData/self.dt);
rm_this = ismember(uncertain_spikes,delete_these_spikes);
self.handles.ax.uncertain_spikes(channel).XData(rm_this) = [];
self.handles.ax.uncertain_spikes(channel).YData(rm_this) = [];

self.showSpikes;