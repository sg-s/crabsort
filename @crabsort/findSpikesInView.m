% this function finds spikes in view
% called when sliders are moved in the find spikes popup

function findSpikesInView(self,parameter,value)

if isempty(self.channel_to_work_with)
    return
else
    channel = self.channel_to_work_with;
end

values = self.handles.puppeteer_handle.parameter_values;
parameters = self.handles.puppeteer_handle.parameter_names;
for i = 1:length(parameters)
    self.sdp.(parameters{i}) = values(i);
end


% figure out which channel to work with
V = self.raw_data(:,channel).*self.mask(:,channel);


if any(isnan(V))
    cprintf('red','\n[WARN] ')
    cprintf('NaNs found in voltage trace. Cannot continue.' )
    return
end


MinPeakHeight = self.sdp.MinPeakHeight;
MinPeakProminence = self.sdp.MinPeakProminence;
Threshold = self.sdp.Threshold;
MinPeakDistance = ceil(self.sdp.MinPeakDistance/(self.dt*1e3));
MinPeakWidth = ceil(self.sdp.MinPeakWidth/(self.dt*1e3));
MaxPeakWidth = ceil(self.sdp.MaxPeakWidth/(self.dt*1e3));
MaxPeakHeight = self.sdp.MaxPeakHeight;

xlim = self.handles.ax.ax(channel).XLim;
a = find(self.time >= xlim(1), 1, 'first');
z = find(self.time <= xlim(2), 1, 'last');
V = V(a:z);
if ~self.handles.spike_sign_control.Value
    V = -V;
end

[~,loc] = findpeaks(V,'MinPeakHeight',MinPeakHeight,'MinPeakProminence',MinPeakProminence,'Threshold',Threshold,'MinPeakDistance',MinPeakDistance,'MinPeakWidth',MinPeakWidth,'MaxPeakWidth',MaxPeakWidth);
loc(V(loc) > MaxPeakHeight) = [];

self.handles.main_fig.Name = [self.file_name ' -- found ' oval(length(loc)) ' spikes in current view'];
self.putative_spikes(:,self.channel_to_work_with) = 0;
self.putative_spikes(loc+a-1,channel) = 1;
drawnow

