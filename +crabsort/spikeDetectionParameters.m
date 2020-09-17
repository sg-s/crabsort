% this class stores attributes used to
% detect spikes in a trace 

classdef spikeDetectionParameters < Hashable


properties


	% these go directly into findpeaks
	MinPeakHeight  (1,1) double {mustBeFinite} = 10
	MinPeakProminence  (1,1) double {mustBeFinite} = 1
	Threshold  (1,1) double {mustBeFinite} = 0
	MinPeakDistance  (1,1) double {mustBeFinite} = 0
	MinPeakWidth  (1,1) double {mustBeFinite, mustBeNonnegative}  = 0
	MaxPeakWidth  (1,1) double {mustBeFinite} = 1e3

	% some extra parameters
	MaxPeakHeight  (1,1) double {mustBeFinite} = 10
	spike_sign  (1,1) logical = true
	t_before  (1,1) double {mustBeFinite, mustBePositive} = 4
	t_after  (1,1) double {mustBeFinite, mustBePositive} = 5
	

end



methods

	function H = hash(self)

		self2 = self;
		self2.MinPeakProminence = 0;
		self2.Threshold = 0;
		self2.MinPeakHeight = 0;
		self2.MaxPeakHeight = 0;
		H = hash@Hashable(self2);

	end

	% has the SDP been changed from default values?
	function TF = isdefault(self)
		sdp = crabsort.spikeDetectionParameters;
		TF = strcmp(self.hash,sdp.hash);
	end

end


end % classdef