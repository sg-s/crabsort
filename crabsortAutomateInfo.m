classdef crabsortAutomateInfo


properties

	spike_prom = []
	spike_sign = []
	other_nerves = {}
	other_nerves_control = []

end



methods

	function automate_info = crabsortAutomateInfo(N)

		% matlab stupidity, see
		% https://www.mathworks.com/help/matlab/matlab_oop/initialize-object-arrays.html
		if nargin == 0
			return
		end

		for i = 1:N
			automate_info(i).spike_prom = [];
			automate_info(i).spike_sign = [];
			automate_info(i).other_nerves = {};
			automate_info(i).other_nerves_control = [];
		end


	end

end


end % classdef 


