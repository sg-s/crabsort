function updateWatchMe(self,src,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


channel = self.channel_to_work_with;


if src.Value == 0
	self.watch_me = true;
	src.BackgroundColor = [1 0 0];
	src.Value = 1;

	% make sure every other recording is off
	for i = 1:self.n_channels
		if i == channel
			continue
		end
		self.handles.ax.recording(i).BackgroundColor = [.9 .9 .9];
		self.handles.ax.recording(i).Value = 0;
	end
else
	self.watch_me = false;
	src.BackgroundColor = [.9 .9 .9];
	src.Value = 0;
	
end