function updateCursor(self,src,~)

if self.handles.mode_off == src
	set(self.handles.main_fig,'pointer','arrow');
	drawnow
	return
end

if self.handles.mode_new_spike == src
	set(self.handles.main_fig,'pointer','crosshair');
	drawnow
	return
end
