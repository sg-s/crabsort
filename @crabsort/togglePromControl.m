%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% switches between manual and automatic spike
% prominence detection

function [] = togglePromControl(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if get(self.handles.prom_auto_control,'Value')
	set(self.handles.prom_auto_control,'String','AUTO')
	set(self.handles.prom_ub_control,'Visible','off')
	set(self.handles.spike_prom_slider,'Visible','off')

else
	set(self.handles.prom_auto_control,'String','MANUAL')
	set(self.handles.prom_ub_control,'Visible','on')
	set(self.handles.spike_prom_slider,'Visible','on')
end

self.findSpikes;