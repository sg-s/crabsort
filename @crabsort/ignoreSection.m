function ignoreSection(self,src,~)

if isempty(self.channel_to_work_with)
	xlim = vertcat(self.handles.ax.ax.XLim);
	xlim = xlim(strcmp({self.handles.ax.ax.Visible},'on'),:);
	xlim = round(xlim(1,:)/self.dt);
else
	xlim = round(self.handles.ax.ax(self.channel_to_work_with).XLim/self.dt);
end

if xlim(1) < 1
	xlim(1) = 1;
end

if xlim(2) > self.raw_data_size(1)
	xlim(2) = self.raw_data_size(1);
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


% remove all spikes when mask is false
global_mask = max(self.mask,[],2);
nerves = fieldnames(self.spikes);
for i = 1:length(nerves)
	neurons = fieldnames(self.spikes.(nerves{i}));
	for j = 1:length(neurons)
		self.spikes.(nerves{i}).(neurons{j})(global_mask(self.spikes.(nerves{i}).(neurons{j})) == 0) = [];
	end
end





% update the mean removal
for i = 1:self.n_channels
	self.removeMean(i);
end

self.showSpikes;

% redraw 
self.scroll(self.handles.ax.ax(1).XLim);
