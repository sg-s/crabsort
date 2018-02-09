function updateWatchMe(self,src,~)

channel = self.channel_to_work_with;

if strcmp(src.Checked,'on')
	src.Checked = 'off';
	self.watch_me = false;
	self.handles.recording(channel).Visible = 'off';
else
	src.Checked = 'on';
	self.watch_me = true;
	self.handles.recording(channel).Visible = 'on';
end