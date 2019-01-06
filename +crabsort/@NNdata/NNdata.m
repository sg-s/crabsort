classdef  NNdata < VectorObject & Hashable


properties


	raw_data
	file_idx
	spiketimes
	label_idx


	% neural network performance 
	accuracy@double
	accuracy_hash@char
	acceptable_accuracy@double = 98


	% spike detection parameters
	sdp@crabsort.spikeDetectionParameters = crabsort.spikeDetectionParameters.empty()

	% define what a data frame is
	other_nerves@char = ''
	other_nerves_control@logical

end


methods

	function self = NNdata(N)


		% matlab stupidity, see
		% https://www.mathworks.com/help/matlab/matlab_oop/initialize-object-arrays.html
		if nargin == 0
			N = 1;
		end

		self = self@VectorObject(N);
	end


	function self = set.accuracy(self,value)
		self.accuracy = value;
		if isempty(value)
			return
		end

		d = dbstack;
		if any(strcmp({d.name},'NNdata.hash'))
			return
		end
		self.accuracy_hash = self.hash;
	end


	% overload the hash method
	% because we don't want some things to be hashed
	function H = hash(self)
		self.accuracy_hash = '0';
		self.accuracy = 0;
		self.acceptable_accuracy = 0;
		
		H = hash@Hashable(self);
	end



	function TF = isMoreTrainingNeeded(self)

		if ~strcmp(self.hash,self.accuracy_hash)
			% accuracy hash does not match data, so something has changed,
			% so must retrain
			TF = true;
			return
		end

		if self.accuracy > self.acceptable_accuracy
			TF = false;
			return
		else
			TF = true;
			return
		end

	end

end % methods

end % classdef