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

is_temp = false;

is_intracellular = any(isstrprop(self.common.data_channel_names{idx},'upper'));

try
	if strcmp(self.common.data_channel_names{idx},'temperature')
		is_temp = true;
	end
catch
end


if ~is_temp && ~is_intracellular
	% normal extracellular recording
	yl = (src.Value)*e;
	self.handles.ax(idx).YLim = [-yl yl];
	self.handles.ax(idx).YTickMode = 'auto';
	self.handles.ax(idx).YTick = self.handles.ax(idx).YTick(self.handles.ax(idx).YTick>=0);
elseif is_temp
	self.handles.ax(idx).YLim = [10 35];
	self.handles.ax(idx).YTickMode = 'auto';
elseif is_intracellular
	% find the mean
	a = find(self.time > self.handles.ax(idx).XLim(1),1,'first');
	z = find(self.time > self.handles.ax(idx).XLim(2),1,'first');
	m = mean(self.raw_data(a:z,idx));
	yl = (src.Value)*100;
	self.handles.ax(idx).YLim = [m-yl m+yl];
	self.handles.ax(idx).YTickMode = 'auto';
end


self.handles.prom_ub_control.String = mat2str(yl);
self.updateSpikePromSlider(0);

self.channel_ylims(idx) = yl;