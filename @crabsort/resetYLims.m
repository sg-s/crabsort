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

self.handles.ax(idx).YTickMode = 'auto';

self.handles.ax(idx).YTick = self.handles.ax(idx).YTick(self.handles.ax(idx).YTick>=0);


self.handles.prom_ub_control.String = mat2str(yl);
self.updateSpikePromSlider(0);

self.channel_ylims(idx) = yl;