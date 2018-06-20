function updateWatchMe(self,src,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


channel = self.channel_to_work_with;

if strcmp(src.Checked,'on')
	src.Checked = 'off';
	self.watch_me = false;
	self.handles.ax.recording(channel).Visible = 'off';
else
	src.Checked = 'on';
	self.watch_me = true;
	self.handles.ax.recording(channel).Visible = 'on';
end