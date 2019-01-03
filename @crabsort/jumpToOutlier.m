function jumpToOutlier(self,direction)

% find outliers 
if isempty(self.channel_to_work_with)
	return
else
	channel = self.channel_to_work_with;
end
spiketimes = find(self.getSpikesOnThisNerve);
if isempty(spiketimes)
	self.handles.main_fig.Name = [self.file_name ' -- No identified spikes'];
	return
end
V = self.getSnippets(channel,spiketimes);
E = abs(zscore(sum(abs(V - mean(V,2)))));
outliers = E > 5;

if ~any(outliers)
	self.handles.main_fig.Name = [self.file_name ' -- No outliers'];
	return
elseif mean(outliers) > .1
	self.handles.main_fig.Name = [self.file_name ' -- No outliers'];
	return
end
outliers = spiketimes(outliers);



outliers = outliers*self.dt;

xx = self.handles.ax.ax(channel).XLim;
xrange = diff(self.handles.ax.ax(channel).XLim);



switch direction

case 'right'
	xx = xx(2);
	outliers(outliers<xx) = [];
	
case 'left'
	xx = xx(1);
	outliers(outliers>xx) = [];

otherwise
	error('unknown argument')
end
	

if isempty(outliers)
	self.handles.main_fig.Name = [self.file_name ' -- No outliers'];
	return
end
switch direction
case 'right'
	outliers = outliers(1);
case 'left'
	outliers = outliers(end);
end



self.handles.ax.spike_marker(channel).XData  = [outliers outliers];
self.handles.ax.spike_marker(channel).YData = self.handles.ax.ax(channel).YLim;

self.handles.ax.ax(channel).XLim = [outliers - xrange/2 outliers + xrange/2];


self.scroll([outliers - xrange/2 outliers + xrange/2])


self.handles.main_fig.Name = [self.file_name ' -- Possible outlier detected'];
