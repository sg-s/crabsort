% this class stores attributes used to
% detect spikes in a trace 

classdef spikeDetectionParameters < Hashable


properties


	% these go directly into findpeaks
	MinPeakHeight@double
	MinPeakProminence@double
	Threshold@double
	MinPeakDistance@double
	MinPeakWidth@double 
	MaxPeakWidth@double

	% some extra parameters
	MaxPeakHeight@double
	spike_sign@logical
	t_before@double 
	t_after@double
	

end



methods (Static)

	% we're overloading the empty method
	% so that we can define some defaults
	function self = empty()

		self = crabsort.spikeDetectionParameters();
	end

	function self = default()

		self = crabsort.spikeDetectionParameters();
		
		self.MinPeakHeight = 0;
		self.MaxPeakHeight = Inf;
		self.MinPeakProminence = 1;
		self.Threshold = 0;		
		self.MinPeakDistance = 0;
		self.MinPeakWidth = 0;
		self.MaxPeakWidth = 1e3;
		self.spike_sign = true;
		self.t_before = 4;
		self.t_after = 5;

	end

end



end % classdef