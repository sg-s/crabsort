%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% changes the ylims of a particular channel and fixes it there

function resetYLims(self,src,~)

if isempty(self.channel_to_work_with)
	return
end

channel = self.channel_to_work_with;



if strcmp(self.common.data_channel_names{channel},'temperature')
	self.handles.ax.ax(channel).YLim = [5 35];
	self.handles.ax.ax(channel).YTickMode = 'auto';
	return
end



a = find(self.time >= self.handles.ax.ax(channel).XLim(1),1,'first');
z = find(self.time >= self.handles.ax.ax(channel).XLim(2),1,'first');
min_value = min(self.raw_data(a:z,channel));
max_value = max(self.raw_data(a:z,channel));
mean_value = median(self.raw_data(a:z,channel));
if self.isIntracellular(channel)
	yrange = max_value - min_value + 1;
else
	yrange = max_value - min_value;
end
yl = (src.Value)*yrange;

self.handles.ax.ax(channel).YLim = [mean_value-yl mean_value+yl];
self.handles.ax.ax(channel).YTickMode = 'auto';


if self.channel_stage(channel) == 0
	self.sdp.MinPeakProminence = yl;
	self.sdp.MaxPeakHeight = 2*yl;
end

self.channel_ylims(channel) = yl;
