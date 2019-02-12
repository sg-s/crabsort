function jumpToOutlier(self,direction)

% find outliers 
if isempty(self.channel_to_work_with)
	return
else
	channel = self.channel_to_work_with;
end
spiketimes = find(self.getSpikesOnThisNerve);
if isempty(spiketimes)
	self.say('No identified spikes');
	beep
	return
end
V = self.getSnippets(channel,spiketimes);
E = abs(zscore(sum(abs(V - mean(V,2)))));


spiketimes = spiketimes*self.dt;

xx = self.handles.ax.ax(channel).XLim;
xrange = diff(self.handles.ax.ax(channel).XLim);

weirdness_in_view = max(E(spiketimes <= xx(2) & spiketimes >= xx(1)));


switch direction

case 'up'
	% go to the weirdest spike

	[~,outliers] = max(E);
	outliers = outliers(1);

	outliers = spiketimes(outliers);
	
case 'down'
	% got to a less weird spike

	sE = sort(E,'descend');
	outliers = find(sE<weirdness_in_view,1,'first');
	if isempty(outliers)
		beep
		return
	end
	outliers = spiketimes(E == sE(outliers));

otherwise
	error('unknown argument')
end
	



self.handles.ax.spike_marker(channel).XData  = [outliers outliers];
self.handles.ax.spike_marker(channel).YData = self.handles.ax.ax(channel).YLim;

self.handles.ax.ax(channel).XLim = [outliers - xrange/2 outliers + xrange/2];


self.scroll([outliers - xrange/2 outliers + xrange/2])


self.say('Possible outlier detected');
