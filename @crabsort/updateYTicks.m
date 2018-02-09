%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% small helper method to fix some YTicks


function updateYTicks(self,channel)


if strcmp(self.common.data_channel_names{channel},'temperature')
    self.handles.ax(channel).YLim = [5 35];
    self.handles.ax(channel).YTickMode = 'auto';

    return
end

% if it's intracellular
temp = isstrprop(self.common.data_channel_names{channel},'upper');
if any(temp)
	self.handles.ax(channel).YGrid = 'on';
	self.handles.ax(channel).YTickMode = 'auto';
else
    % extracellular
    self.removeMean(channel);
end

