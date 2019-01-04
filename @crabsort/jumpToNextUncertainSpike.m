

function jumpToNextUncertainSpike(self)

if isempty(self.channel_to_work_with)
	self.handles.main_fig.Name = [self.file_name ' -- No channel chosen'];
	beep
	return
else
	channel = self.channel_to_work_with;
end

uncertain_spikes = self.handles.ax.uncertain_spikes(channel).XData;

if isempty(uncertain_spikes)
	self.handles.main_fig.Name = [self.file_name ' -- No uncertain spikes'];
	return
end

if any(isnan(uncertain_spikes))
	self.handles.main_fig.Name = [self.file_name ' -- No uncertain spikes'];
	return
end


xx = self.handles.ax.ax(channel).XLim;
xrange = diff(self.handles.ax.ax(channel).XLim);



xx = xx(2);
uncertain_spikes(uncertain_spikes<xx) = [];
	


if isempty(uncertain_spikes)
	self.handles.main_fig.Name = [self.file_name ' -- No uncertain spikes'];
	return
end

uncertain_spikes = uncertain_spikes(1);


self.scroll([uncertain_spikes - xrange/2 uncertain_spikes + xrange/2])


self.handles.main_fig.Name = [self.file_name ' -- Resolve this ambiguous spike'];
