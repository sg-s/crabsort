function makeISIPlot(self,~,~)

if self.verbosity > 9
	disp(mfilename)
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

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on


for i = 1:length(neurons)
	subplot(length(neurons),1,i); hold on

	spiketimes = self.spikes.(nerve).(neurons{i});
	isis = [diff(spiketimes); NaN];

	plot(spiketimes*self.dt, isis*self.dt,'k.')

	ylabel([neurons{i} ' ISI (s)'])


	set(gca,'YScale','log')

end
xlabel('Time (s)')


figlib.pretty