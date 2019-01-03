function keyPressCallback(self,src,value)


if strcmp(value.Key,'escape')
	self.channel_to_work_with = [];
elseif strcmp(value.Key ,'rightarrow')
	self.jumpToOutlier('right')
elseif strcmp(value.Key ,'leftarrow')
	self.jumpToOutlier('left')

end
