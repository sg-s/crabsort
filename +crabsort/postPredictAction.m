classdef postPredictAction



properties

	channel char
	method (1,1) function_handle = @() []
	arguments cell


end % props


methods

	function self = postPredictAction(channel, method, arguments)
		self.channel = channel;
		self.method = method;
		self.arguments = arguments;

	end % constructor


end  % methods


end % classdef 