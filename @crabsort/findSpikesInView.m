% this function finds spikes in view
% called when sliders are moved in the find spikes popup

function findSpikesInView(self,parameter,value)

if isempty(self.channel_to_work_with)
    return
else
    channel = self.channel_to_work_with;
end

if nargin == 3
	parameter = parameter{1};
	self.sdp.(parameter) = value;
end

% figure out which channel to work with
V = self.raw_data(:,channel).*self.mask(:,channel);


if any(isnan(V))
    cprintf('red','\n[WARN] ')
    cprintf('NaNs found in voltage trace. Cannot continue.' )
    return
end


mpp = self.sdp.spike_prom;
mpd = ceil(self.sdp.minimum_peak_distance/(self.dt*1e3));
mpw = ceil(self.sdp.minimum_peak_width/(self.dt*1e3));
v_cutoff = self.sdp.V_cutoff;

xlim = self.handles.ax.ax(channel).XLim;
a = find(self.time >= xlim(1), 1, 'first');
z = find(self.time <= xlim(2), 1, 'last');
V2 = V(a:z);
if ~self.handles.spike_sign_control.Value
    [~,loc] = findpeaks(-V2,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
    loc(V(loc) < -abs(v_cutoff)) = [];
else
    [~,loc] = findpeaks(V2,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
    loc(V(loc) > abs(v_cutoff)) = [];
end
self.handles.main_fig.Name = [self.file_name ' -- found ' oval(length(loc)) ' spikes in current view'];
self.putative_spikes(:,self.channel_to_work_with) = 0;
self.putative_spikes(loc+a-1,channel) = 1;
drawnow

