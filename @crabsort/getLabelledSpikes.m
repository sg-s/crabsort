% get a labelelled set of spikes on this nerve
% works nicely for mulitple units

function [spiketimes, labels] = getLabelledSpikes(self)

if self.verbosity > 9
	disp(mfilename)
end

spiketimes = [];
labels = categorical();

this_nerve = self.common.data_channel_names{self.channel_to_work_with};

if ~isfield(self.spikes,this_nerve)
	disp('No spikes')
	return
end

unit_names = fieldnames(self.spikes.(this_nerve));

if length(unit_names) == 0
	disp('No labelled units')
	return
end

for i = 1:length(unit_names)
	spiketimes = vertcat(spiketimes, self.spikes.(this_nerve).(unit_names{i}));
	labels = vertcat(labels,categorical(repmat(unit_names(i),length(self.spikes.(this_nerve).(unit_names{i})),1)));
end

[spiketimes,idx] = sort(spiketimes);
labels = labels(idx);

