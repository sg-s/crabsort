function  [] = updateSpikePromSlider(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% get the upper bound
ub = str2double(get(s.handles.prom_ub_control,'String'));
current_value = get(s.handles.spike_prom_slider,'Value');

if isnan(ub)
	return
end

if ub <= 0
	return
end

set(s.handles.spike_prom_slider,'Max',ub);

if current_value > ub || current_value < 0
	set(s.handles.spike_prom_slider,'Value',(0+ub)/2);
end

s.findSpikes;