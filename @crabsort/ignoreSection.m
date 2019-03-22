function ignoreSection(self,src,value)


xlim = round(self.handles.ax.ax(1).XLim/self.dt);

if xlim(1) == 0
	xlim(1) = 1;
end

switch src.Text

case 'Ignore this section'
	% update the mask
	for i = 1:self.n_channels
		self.mask(xlim(1):xlim(2),i) = 0;
	end
case 'UNignore this section'
	% update the mask
	for i = 1:self.n_channels
		self.mask(xlim(1):xlim(2),i) = 1;
	end


case 'Ignore sections where data exceeds Y bounds'
	channel = self.channel_to_work_with;
	if isempty(channel)
		return
	end

	ylim = self.handles.ax.ax(channel).YLim;

	ignore_this = self.raw_data(:,channel) < ylim(1) | self.raw_data(:,channel) > ylim(2);

	self.mask(ignore_this,:) = 0;

otherwise
	error('What')
end


% redraw 
self.scroll(self.handles.ax.ax(1).XLim);
