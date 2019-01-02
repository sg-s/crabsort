

function maskUnmask(self,src,value)

if isempty(self.channel_to_work_with)
	return
end

if src == self.handles.mask_all_control
	self.mask(:,self.channel_to_work_with) = 0;
elseif src == self.handles.unmask_all_control
	self.mask(:,self.channel_to_work_with) = 1;
else
	error('Unknown source')
end