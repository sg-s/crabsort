classdef VectorObject


properties

end


methods


	function save(save_here)



	end


	function self = VectorObject(input_arg)

		if nargin == 0 
			return
		end

		if isnumeric(input_arg)
			props = properties(self);


			N = input_arg;
			for i = N:-1:1
				for j = 1:length(props)
					% yes, this 1 is correct, not an i
					eval(['E=' class(self(1).(props{j})) '.empty();'])

					self(i).(props{j}) = E;
				end
			end

		else
			keyboard
		end

		

	end


end


end % classdef 