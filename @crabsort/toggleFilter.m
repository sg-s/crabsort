function [] = toggleFilter(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if get(s.handles.filtermode,'Value')
	set(s.handles.filtermode,'String','Filter is ON')
	s.filter_trace = true;

	% force A and B to update
	s.A = s.A;
	s.B = s.B;

	s.handles.ax1_all_spikes.Visible = 'on';
	s.handles.ax1_A_spikes.Visible = 'on';
	s.handles.ax1_B_spikes.Visible = 'on';
	return
else
	set(s.handles.filtermode,'String','Filter is OFF')
	s.filter_trace = false;
	s.handles.ax1_all_spikes.Visible = 'off';
	s.handles.ax1_A_spikes.Visible = 'off';
	s.handles.ax1_B_spikes.Visible = 'off';
	return
end

