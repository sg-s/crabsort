classdef  crabsortNNdata < VectorObject


properties

	raw_data
	file_idx
	spiketimes
	label_idx

	% neural network performance 
	accuracy
	accuracy_hash


	% spike detection parameters
	spike_prom@double = []
	spike_sign@logical = logical.empty()
	other_nerves@char = ''
	other_nerves_control@logical = logical.empty()

end


methods

	function NNdata = crabsortNNdata(N)


		% matlab stupidity, see
		% https://www.mathworks.com/help/matlab/matlab_oop/initialize-object-arrays.html

		if nargin == 0
			N = 1;
		end

		NNdata = NNdata@VectorObject(N);


	end


	function self = set.accuracy(self,value)
		self.accuracy = value;
		self.accuracy_hash = self.fullHash;
	end


	function H = fullHash(self)
		H{1} = GetMD5([self.raw_data' self.file_idx self.spiketimes self.label_idx]);
		H{2} = self.hash;
		H =  GetMD5([H{:}]);

	end


	% compute hash based on spike detection
	% parameters. this hash is used to identify the
	% NN that is to be used
	function H = hash(self)
		if isempty(self.spike_prom)
			H = repmat('0',1,32);
			return
		end
		if isempty(self.spike_sign)
			H = repmat('0',1,32);
			return
		end
		if isempty(self.other_nerves_control)
			H = repmat('0',1,32);
			return
		end
		H = GetMD5([GetMD5([self.spike_prom self.spike_sign self.other_nerves_control]); self.other_nerves]);
	end


	function TF = isMoreTrainingNeeded(self)

		if ~strcmp(self.fullHash,self.accuracy_hash)
			% accuracy hash does not match data, so something has changed,
			% so must retrain
			TF = true;
			return
		end

		if self.accuracy > 98
			TF = false;
			return
		else
			TF = true;
			return
		end

	end

end % methods

end % classdef