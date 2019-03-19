function purgeUncertainSpikes(self, ~, ~)

channel = self.channel_to_work_with;

if isempty(channel)
	return
end

uncertain_spikes = round(self.handles.ax.uncertain_spikes(channel).XData/self.dt);

spiketimes = self.getLabelledSpikes;

rm_this = ismember(uncertain_spikes,spiketimes);

self.handles.ax.uncertain_spikes(channel).XData(rm_this) = [];
self.handles.ax.uncertain_spikes(channel).YData(rm_this) = [];