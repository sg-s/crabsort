%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% removes means a given channel  

function removeMean(self, channel)


self.raw_data(:,channel) = self.raw_data(:,channel) - mean(self.raw_data(:,channel));

if isempty(self.handles) 
	return
end
if ~isfield(self.handles,'data')
	return
end

% update the YData if need be
if ~strcmp(class(self.handles.data(channel)),'matlab.graphics.chart.primitive.Line')
	return
end
a = find(self.time >= self.handles.data(channel).XData(1),1,'first');
z = find(self.time <= self.handles.data(channel).XData(end),1,'last');
self.handles.data(channel).YData = self.raw_data(a:z,channel);