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

idx = self.channel_to_work_with;

% compute the extremum of the channel
e = max(abs(self.raw_data(:,idx)));

yl = (src.Value)*e;
self.handles.ax(idx).YLim = [-yl yl];

is_temp = false;

try
	if strcmp(self.data_channel_names{idx},'temperature')
		is_temp = true;
	end
catch
end


if ~is_temp
	self.handles.ax(idx).YTickMode = 'auto';
	self.handles.ax(idx).YTick = self.handles.ax(idx).YTick(self.handles.ax(idx).YTick>=0);
else
	self.handles.ax(idx).YLim = [10 35];
	self.handles.ax(idx).YTickMode = 'auto';
end


self.handles.prom_ub_control.String = mat2str(yl);
self.updateSpikePromSlider(0);

self.channel_ylims(idx) = yl;