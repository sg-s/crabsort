function [] =  toggleSpikeSign(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if get(s.handles.spike_sign_control,'Value')
	set(s.handles.spike_sign_control,'String','Finding +ve spikes')
	s.pref.invert_V = false;
else
	set(s.handles.spike_sign_control,'String','Finding -ve spikes')
	s.pref.invert_V = true;
end

s.findSpikes;
