classdef postPredictAction



properties

	channel char
	method (1,1) function_handle = @() []
	args cell


end % props


methods

	function self = postPredictAction(channel, method, args)
		self.channel = channel;
		self.method = method;
		self.args = args;

	end % constructor


end  % methods


end % classdef 