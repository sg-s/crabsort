function purgeUncertainSpikes(self, src, ~)

channel = self.channel_to_work_with;

if isempty(channel)
	return
end


uncertain_spikes = round(self.handles.ax.uncertain_spikes(channel).XData/self.dt);
spiketimes = self.getLabelledSpikes;

if strcmp(src.Text,'Purge uncertain spikes...')
	rm_this = ismember(uncertain_spikes,spiketimes);
elseif strcmp(src.Text,'Purge uncertain noise...')
	rm_this = ~ismember(uncertain_spikes,spiketimes);
end


self.handles.ax.uncertain_spikes(channel).XData(rm_this) = [];
self.handles.ax.uncertain_spikes(channel).YData(rm_this) = [];