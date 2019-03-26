function ignoreSection(self,src,~)


xlim = round(self.handles.ax.ax(self.channel_to_work_with).XLim/self.dt);

if xlim(1) == 0
	xlim(1) = 1;
end

switch src.Text

case 'Ignore this section'
	% update the mask
	self.mask(xlim(1):xlim(2),:) = 0;

case 'UNignore this section'
	% update the mask
	self.mask(xlim(1):xlim(2),:) = 1;



case 'Ignore sections where data exceeds Y bounds'
	channel = self.channel_to_work_with;
	if isempty(channel)
		return
	end

	ylim = self.handles.ax.ax(channel).YLim;

	ignore_this = self.raw_data(:,channel) < ylim(1) | self.raw_data(:,channel) > ylim(2);

	ignore_this = find(ignore_this);

	% also include a buffer around every artifact
	a = 1;
	z = length(self.mask);
	buffer = round(self.pref.artifact_buffer/self.dt);
	for i = 1:length(ignore_this)
		if self.mask(ignore_this(i),1) == 0
			continue
		end
		a = ignore_this(i)-buffer;
		if a < 1
			a = 1;
		end
		z = ignore_this(i)+buffer;
		if z > self.raw_data_size(1)
			z = self.raw_data_size(1);
		end
		self.mask(a:z,:) = 0;
	end


otherwise
	error('What')
end


% redraw 
self.scroll(self.handles.ax.ax(1).XLim);
