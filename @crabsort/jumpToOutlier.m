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
P = pca(V);
E = (P(:,1) - median(P(:,1))).^2 + (P(:,2) - median(P(:,2))).^2;
outliers = (E>(median(E*10)));
if ~any(outliers)
	self.handles.main_fig.Name = [self.file_name ' -- No outliers'];
	return
end
outliers = spiketimes(outliers);

xrange = diff(self.handles.ax.ax(channel).XLim);


outliers = outliers*self.dt;

switch direction
case 'right'
	xx = self.handles.ax.ax(channel).XLim(1);
	outliers(outliers<xx) = [];
case 'left'
	xx = self.handles.ax.ax(channel).XLim(2);
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
self.handles.ax.ax(channel).XLim = [outliers - xrange/2 outliers + xrange/2];
% fake a scroll
event = struct;
event.VerticalScrollCount = 0;
self.scroll([],event)

self.handles.main_fig.Name = [self.file_name ' -- Possible outlier detected'];
