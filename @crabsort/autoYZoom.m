function autoYZoom(self,src,event)

m = min(self.raw_data(:,self.channel_to_work_with));
M = max(self.raw_data(:,self.channel_to_work_with));

self.handles.ax.ax(self.channel_to_work_with).YLim = [m M];

self.channel_ylims(self.channel_to_work_with) = max(abs([m M]));

drawnow