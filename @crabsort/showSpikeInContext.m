% showSpikeInContext
% 
% created by Srinivas Gorur-Shandilya at 1:04 , 11 September 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

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

set(self.handles.ax(self.channel_to_work_with),'XLim',xlim)