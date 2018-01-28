%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% clear all linked data that would have been
% used to train a TF network for this channel
function clearTFData(self,~,~)

try
	self.tf_data(self.channel_to_work_with) = [];
catch
end