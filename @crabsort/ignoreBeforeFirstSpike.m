function ignoreBeforeFirstSpike(self,~,~)

first_spike = Inf;
nerves = fieldnames(self.spikes);
for i = 1:length(nerves)
	neurons = fieldnames(self.spikes.(nerves{i}));

	for j = 1:length(neurons)
		this_spike = min(self.spikes.(nerves{i}).(neurons{j}));
		if isempty(this_spike)
			continue
		end

		first_spike = min([first_spike; this_spike]);
	end

end

self.mask(1:first_spike,:) = 0;

% redraw
self.scroll(self.handles.ax.ax(1).XLim);