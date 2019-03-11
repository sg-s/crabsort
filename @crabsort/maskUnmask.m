

function maskUnmask(self,src,~)

if isempty(self.channel_to_work_with)
	return
end

if src == self.handles.mask_all_control
	self.mask(:,self.channel_to_work_with) = 0;
elseif src == self.handles.unmask_all_control
	self.mask(:,self.channel_to_work_with) = 1;
elseif src == self.handles.mask_all_but_view_control
	XLim = self.handles.ax.ax(self.channel_to_work_with).XLim;
	XLim = floor(XLim/self.dt);
	self.mask(:,self.channel_to_work_with) = 1;
	self.mask(1:XLim(1),self.channel_to_work_with) = 0;
	self.mask(XLim(2):end,self.channel_to_work_with) = 0;
end