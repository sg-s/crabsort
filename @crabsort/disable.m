
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% disable all controls 

function disable(self, thing)

try
	thing.Enable = 'off';
catch
end


for i = 1:length(thing.Children)
	thing.Children(i).Enable = 'off';
end
