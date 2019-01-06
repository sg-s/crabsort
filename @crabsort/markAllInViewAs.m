
function markAllInViewAs(self,src,value)


if isempty(self.channel_to_work_with)
	return
else
	channel = self.channel_to_work_with;
end

% find spikes in this view
self.findSpikes;

spiketimes = find(self.putative_spikes(:,channel));

if isempty(spiketimes)
	return
end

xx = round(self.handles.ax.ax(channel).XLim/self.dt);
spiketimes(spiketimes<xx(1)) = [];
spiketimes(spiketimes>xx(2)) = [];

if isempty(spiketimes)
	return
end

self.putative_spikes(:,channel) = 0;
self.putative_spikes(spiketimes,channel) = 1;

if strcmp(src.String{src.Value},'Noise')

	% mark as noise, and add to NNdata
	self.NNsync(); 
	self.getDataToReduce;

	for i = 1:length(spiketimes)
		this_spike = spiketimes(i);
		self.common.NNdata(channel) = self.common.NNdata(channel).addDataFrame(self.data_to_reduce(:,i),self.getFileSequence,this_spike,0);
	end

	self.putative_spikes(:,channel) = 0;
	self.showSpikes;
	return
else
	keyboard
end