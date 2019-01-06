% this class stores attributes used to
% detect spikes in a trace 

classdef spikeDetectionParameters


properties

	spike_prom@double 
	spike_sign@logical
	time_bw_spikes@double 
	t_before@double 
	t_after@double
	minimum_peak_width@double 
	minimum_peak_distance@double 
	V_cutoff@double

end



methods (Static)

	% we're overloading the empty method
	% so that we can define some defaults
	function self = empty()

		self = crabsort.spikeDetectionParameters();
	end

	function self = default()
		self = crabsort.spikeDetectionParameters();
		self.spike_prom = 1;
		self.spike_sign = true;
		self.time_bw_spikes = 0;
		self.t_before = 4;
		self.t_after = 5;
		self.minimum_peak_distance = 0;
		self.minimum_peak_width = 0;
		self.V_cutoff = NaN;
	end

end


end % classdef