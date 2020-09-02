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
	% no spikes to show. let's show a compressed version of the data instead.
	V = self.raw_data(:,channel);

	V(self.mask(:,channel)==0) = NaN;

	deltat = .01;
	ChunkSize = ceil(deltat/self.dt); % 10 ms chunks
	V = V(1:floor(length(V)/ChunkSize)*ChunkSize);
	V = reshape(V,ChunkSize,length(V)/ChunkSize);
	max_values = max(V);
	min_values = min(V);
	time = veclib.interleave((1:size(V,2))*deltat,(1:size(V,2))*deltat);
	Y =  veclib.interleave(max_values,min_values);
	self.handles.isi_data_maxmin.XData = time;
	self.handles.isi_data_maxmin.YData = Y;
	ylabel(self.handles.isi_ax,nerve)
	self.handles.isi_ax.YScale = 'linear';
	yl = [min(Y) max(Y)];

else

	self.handles.isi_ax.YScale = 'log';
	ylabel(self.handles.isi_ax,'ISI (s)')

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

	

end

self.handles.isi_ax.YLim = yl;

self.handles.isi_ax.XLim = [0 self.time(end)];
self.handles.isi_plot_left.YData = yl;
self.handles.isi_plot_right.YData = yl;