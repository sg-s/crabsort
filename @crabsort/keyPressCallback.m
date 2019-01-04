function keyPressCallback(self,src,value)


if strcmp(value.Key,'escape')
	self.channel_to_work_with = [];
elseif strcmp(value.Key ,'rightarrow') & any(strcmp(value.Modifier,'shift'))
	self.jumpToOutlier('right')
elseif strcmp(value.Key ,'leftarrow') & any(strcmp(value.Modifier,'shift'))
	self.jumpToOutlier('left')
elseif strcmp(value.Key,'p')
	self.redo;
	self.NNpredict;
else
	% do nothing
end
