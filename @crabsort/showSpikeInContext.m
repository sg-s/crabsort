% showSpikeInContext
% 
% created by Srinivas Gorur-Shandilya at 1:04 , 11 September 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function showSpikeInContext(s,data,idx,this_pt)

handles = s.handles;

pref = s.pref;

t = pref.deltat*(1:length(data.V));
set(handles.ax1_data,'XData',t,'YData',data.V)
set(handles.ax1,'XLim',[data.loc(this_pt)*pref.deltat - pref.context_width data.loc(this_pt)*pref.deltat + pref.context_width]);
yy = get(handles.ax1,'YLim');

% show clicked point with a vertical red line
set(handles.ax1_spike_marker,'XData',[data.loc(this_pt) data.loc(this_pt)]*pref.deltat,'YData',yy,'Color','r','Visible','on');

% plot A and B
set(handles.ax1_A_spikes,'XData',data.loc(idx == 1)*pref.deltat,'YData',data.V(data.loc(idx == 1)),'Color','r','LineStyle','none','Marker','o');
set(handles.ax1_B_spikes,'XData',data.loc(idx == 2)*pref.deltat,'YData',data.V(data.loc(idx == 2)),'Color','b','LineStyle','none','Marker','o');
set(handles.ax1_all_spikes,'XData',data.loc(idx == 3)*pref.deltat,'YData',data.V(data.loc(idx == 3)),'Color','k','LineStyle','none','Marker','x');

s.handles = handles;