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

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


channel = self.channel_to_work_with;

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


yy = self.handles.ax.ax(channel).YLim;

% show clicked point with a vertical red line
set(self.handles.ax.spike_marker(channel),'XData',[self.time(this_spike) self.time(this_spike)],'YData',yy,'Color','r','Visible','on');

% update the X and Y data since we don't want to show everything
a = find(self.time >= xlim(1), 1, 'first');
z = find(self.time <= xlim(2), 1, 'last');

for i = 1:length(self.handles.ax.data)
    self.handles.ax.ax(i).XLim = xlim;
    self.handles.ax.data(i).XData = self.time(a:z);
    self.handles.ax.data(i).YData = self.raw_data(a:z,i);
end

% change the Y-axis so that we can actually see something, if it's intracellular 

is_intracellular = any(isstrprop(self.common.data_channel_names{channel},'upper'));
if is_intracellular
	V = self.raw_data(a:z,channel);
	self.handles.ax.ax(channel).YLim = [min(V) max(V)];
end