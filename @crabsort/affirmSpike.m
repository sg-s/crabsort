% affirms a spike to be something
% and adds it to NNdata

function affirmSpike(self, channel, spike_position, spike_name)


self.loadSDPFromNNdata;
self.putative_spikes(:,channel) = 0;
self.putative_spikes(spike_position,channel) = 1;
self.getDataToReduce;

self.common.NNdata(channel) = self.common.NNdata(channel).addDataFrame(self.data_to_reduce,self.getFileSequence,spike_position,categorical({spike_name}));


% remove from uncertain spikes
uncertain_spikes = round(self.handles.ax.uncertain_spikes(channel).XData/self.dt);

self.handles.ax.uncertain_spikes(channel).XData(uncertain_spikes == spike_position) = [];
self.handles.ax.uncertain_spikes(channel).YData(uncertain_spikes == spike_position) = [];