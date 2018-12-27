classdef  crabsortNNdata


properties

	raw_data
	file_idx
	spiketimes
	label_idx


end


methods

	function NNdata = crabsortNNdata(N)

		% matlab stupidity, see
		% https://www.mathworks.com/help/matlab/matlab_oop/initialize-object-arrays.html
		if nargin == 0
			return
		end

		for i = N:-1:1
			NNdata(i).raw_data = [];
			NNdata(i).file_idx = [];
			NNdata(i).spiketimes = [];
			NNdata(i).label_idx = [];
		end


	end


end

end