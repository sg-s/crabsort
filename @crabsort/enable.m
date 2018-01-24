
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% enables all controls 

function enable(self, thing)

try
	thing.Enable = 'on';
catch
end

try
	for i = 1:length(thing.Children)
		try
			thing.Children(i).Enable = 'on';
		catch
		end
	end

catch
end