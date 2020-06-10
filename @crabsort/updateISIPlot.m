function updateISIPlot(self,~,~)

if self.verbosity > 9
	disp(mfilename)
end

% first clear all data
for i = 1:length(self.handles.isi_plot)
	self.handles.isi_plot(i).XData = NaN;
	self.handles.isi_plot(i).YData = NaN;
end


channel = self.channel_to_work_with;

if isempty(channel)
	return
end

nerve = self.common.data_channel_names{channel};

if ~isfield(self.spikes,nerve)
	return
end

neurons = fieldnames(self.spikes.(nerve));


yl = [Inf -Inf];

for i = length(neurons):-1:1

	spiketimes = self.spikes.(nerve).(neurons{i});
	isis = [diff(spiketimes); NaN];

	if isempty(spiketimes)
		continue
	end


	self.handles.isi_plot(i).XData = spiketimes*self.dt;
	self.handles.isi_plot(i).YData = isis*self.dt;


	yl(1) = min([yl(1) nanmin(isis*self.dt)]);
	yl(2) = max([yl(2) nanmax(isis*self.dt)]);

end

if yl(1) == yl(2)
	yl(2) = yl(1) + 1;
end

if any(isinf(yl))
	yl = [1 2];
end

self.handles.isi_ax.YLim = yl;
