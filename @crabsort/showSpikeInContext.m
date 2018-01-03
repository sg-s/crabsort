% showSpikeInContext
%
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% created by Srinivas Gorur-Shandilya 
% https://srinivas.gs/

function showSpikeInContext(self,idx)

handles = self.handles;

putative_spikes = find(self.putative_spikes(:,self.channel_to_work_with));
this_spike = putative_spikes(idx);

xlim(2) = self.time(this_spike) + self.pref.context_width;
xlim(1) = self.time(this_spike) - self.pref.context_width;

if xlim(1) < 0 
	xlim(1) = 0;
end

if xlim(2) > max(self.time)
	xlim(2) = max(self.time);
end


yy = get(handles.ax(self.channel_to_work_with),'YLim');

% show clicked point with a vertical red line
set(self.handles.spike_marker(self.channel_to_work_with),'XData',[self.time(this_spike) self.time(this_spike)],'YData',yy,'Color','r','Visible','on');

% update the X and Y data since we don't want to show everything
a = find(self.time >= xlim(1), 1, 'first');
z = find(self.time <= xlim(2), 1, 'last');

for i = 1:length(self.handles.data)
    self.handles.ax(i).XLim = xlim;
    self.handles.data(i).XData = self.time(a:z);
    self.handles.data(i).YData = self.raw_data(a:z,i);
end