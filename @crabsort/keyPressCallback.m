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
	% to to first five seconds 
	xrange = diff(self.handles.ax.ax(1).XLim);
	self.scroll([0 5]);
elseif strcmp(value.Key,'z')
	% go to end
	self.scroll([self.time(end) - 5 self.time(end)])
elseif strcmp(value.Key,'r')
	self.resetZoom;
elseif strcmp(value.Key,'f')
	self.scroll([0 self.time(end)])
elseif strcmp(value.Character,'0')
	self.zeroSpikes;
elseif strcmp(value.Key,'rightarrow') && isempty(value.Modifier)
	self.loadFile(self.handles.next_file_control)
elseif strcmp(value.Key,'leftarrow') && isempty(value.Modifier)
	self.loadFile(self.handles.prev_file_control)
elseif strcmp(value.Key,'uparrow') && isempty(value.Modifier)
	if isempty(self.channel_to_work_with)
		return
	end
	allowed_channels = find(self.common.show_hide_channels);
	idx = find(ismember(find(self.common.show_hide_channels),self.channel_to_work_with))+1;
	if idx > length(allowed_channels)
		return
	end
	self.channel_to_work_with = allowed_channels(idx);
	
elseif strcmp(value.Key,'downarrow') && isempty(value.Modifier)
	if isempty(self.channel_to_work_with)
		return
	end
	allowed_channels = find(self.common.show_hide_channels);
	idx = find(ismember(find(self.common.show_hide_channels),self.channel_to_work_with))-1;
	if idx == 0
		return
	end
	self.channel_to_work_with = allowed_channels(idx);
	
else
	% do nothing
end
