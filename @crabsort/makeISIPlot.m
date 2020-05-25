function makeISIPlot(self,~,~, refresh_only)

if self.verbosity > 9
	disp(mfilename)
end

if nargin < 4
	refresh_only = false;
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


if ~refresh_only
	self.handles.isi_figure = figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
	self.handles.isi_ax = gca;
end



for i = length(neurons):-1:1

	spiketimes = self.spikes.(nerve).(neurons{i});
	isis = [diff(spiketimes); NaN];

	if isempty(spiketimes)
		continue
	end

	if isfield(self.handles,'isi_plot') && isvalid(self.handles.isi_plot(i))
	else
		self.handles.isi_plot(i) = plot(self.handles.isi_ax,NaN,NaN,'k.');
	end

	if ~refresh_only
		subplot(length(neurons),1,i,'ButtonDownFcn',@self.jumpFromISIPlot); hold on
		self.handles.isi_plot(i) = plot(self.handles.isi_ax,spiketimes*self.dt, isis*self.dt,'k.');
		ylabel([neurons{i} ' ISI (s)'])
		set(gca,'YScale','log')

	else
		self.handles.isi_plot(i).XData = spiketimes*self.dt;
		self.handles.isi_plot(i).YData = isis*self.dt;
	end


end

if ~refresh_only
	xlabel('Time (s)')
	figlib.pretty
end
