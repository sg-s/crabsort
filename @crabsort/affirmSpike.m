% affirms a spike to be something
% and adds it to NNdata

function affirmSpike(self, channel, spike_position, spike_name)

arguments
	self (1,1) crabsort
	channel (1,1) double 
	spike_position (1,1) double 
	spike_name char

end

if self.verbosity > 9
	disp(mfilename)
end

if isempty(self.common.NNdata(channel).spiketimes)
	return
end

self.loadSDPFromNNdata;
self.putative_spikes(:,channel) = 0;
self.putative_spikes(spike_position,channel) = 1;
self.getDataToReduce;

self.common.NNdata(channel) = self.common.NNdata(channel).addDataFrame(self.data_to_reduce,self.getFileSequence,spike_position,categorical({spike_name}));


% remove from uncertain spikes
uncertain_spikes = round(self.handles.ax.uncertain_spikes(channel).XData/self.dt);

self.handles.ax.uncertain_spikes(channel).XData(uncertain_spikes == spike_position) = [];
self.handles.ax.uncertain_spikes(channel).YData(uncertain_spikes == spike_position) = [];

% hide pointless spike markers
set(self.handles.ax.found_spikes(channel),'XData',NaN,'YData',NaN);