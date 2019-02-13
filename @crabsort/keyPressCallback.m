function keyPressCallback(self,~,value)


if strcmp(value.Key,'escape')
	self.channel_to_work_with = [];
elseif strcmp(value.Key ,'uparrow') && any(strcmp(value.Modifier,'shift'))
	self.jumpToOutlier('up')
elseif strcmp(value.Key ,'downarrow') && any(strcmp(value.Modifier,'shift'))
	self.jumpToOutlier('down')
elseif strcmp(value.Key,'p')
	self.redo;
	self.NNpredict;
elseif strcmp(value.Key,'space')
	self.jumpToNextUncertainSpike();
elseif strcmp(value.Key,'g')
	self.NNgenerateTrainingData;
elseif strcmp(value.Key,'a')
	% to to first section
	xrange = diff(self.handles.ax.ax(1).XLim);
	self.scroll([0 xrange]);
elseif strcmp(value.Key,'z')
	% go to end
	xrange = diff(self.handles.ax.ax(1).XLim);
	self.scroll([self.time(end) - xrange self.time(end)])
elseif strcmp(value.Key,'r')
	self.resetZoom;
else
	% do nothing
end
