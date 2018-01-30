function updateWatchMe(self,src,~)


if strcmp(src.Checked,'on')
	src.Checked = 'off';
	self.watch_me = false;
else
	src.Checked = 'on';
	self.watch_me = true;
end