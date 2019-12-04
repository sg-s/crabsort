function jumpFromISIPlot(self,~,event)


px = event.IntersectionPoint(1);
py = event.IntersectionPoint(2);

x = event.Source.Children.XData;
y = event.Source.Children.YData;

spiketimes = find(self.getSpikesOnThisNerve)*self.dt;

[~,idx]=nanmin((x - px).^2 + (y-py).^2);

this_spike = spiketimes(idx);


% if it's a left click, jump, if it's a right click, delete
if strcmp(self.handles.isi_plot(1).Parent.Parent.SelectionType,'normal')
	% left click
	xrange = diff(self.handles.ax.ax(self.channel_to_work_with).XLim);
	self.scroll([this_spike - xrange/2 this_spike + xrange/2])
else
	self.rightClickCallback([this_spike, self.raw_data(round(this_spike/self.dt),self.channel_to_work_with)]);
end

