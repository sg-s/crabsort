%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% removes means from identified extracellular channels

function removeMean(self)

for i = 1:length(self.data_channel_names)
	if ~isempty(self.data_channel_names{i}) && ~strcmp(self.data_channel_names{i},'temperature')
		self.raw_data(:,i) = self.raw_data(:,i) - mean(self.raw_data(:,i));
	end
end