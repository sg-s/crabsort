classdef  NNdata < VectorObject 

properties


	raw_data
	file_idx
	spiketimes
	label_idx categorical 


	% timestamps to determine if more training is needed
	timestamp_last_modified char = datestr(now)
	timestamp_last_trained char = datestr(now)


	% neural network performance 
	accuracy (1,1) double = 0
	acceptable_accuracy (1,1) double = 98


	% spike detection parameters
	sdp crabsort.spikeDetectionParameters = crabsort.spikeDetectionParameters.empty()

	% define what a data frame is
	other_nerves char = ''
	other_nerves_control logical

	norm_factor double = 1

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
	end





	function TF = isMoreTrainingNeeded(self)

		if isempty(self.timestamp_last_trained)
			TF = true;
			return
		end


		if datenum(self.timestamp_last_trained) < datenum(self.timestamp_last_modified)
			% NNData modified after last trained, so train more
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