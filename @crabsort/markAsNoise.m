% removes a given spiketime from spikes

function markAsNoise(self,this_nerve,this_spike)

arguments
	self (1,1) crabsort
	this_nerve char
	this_spike double
end

if self.verbosity > 9
	disp(mfilename)
end

if ~isfield(self.spikes,this_nerve)
	return
end

neuron_names = fieldnames(self.spikes.(this_nerve));

for i = 1:length(neuron_names)
	spikes = self.spikes.(this_nerve).(neuron_names{i});
	if any(spikes(spikes==this_spike))
		spikes(spikes == this_spike) = [];
		self.spikes.(this_nerve).(neuron_names{i}) = spikes;
	end
end

self.showSpikes(self.channel_to_work_with);