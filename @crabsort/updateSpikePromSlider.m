%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
%
% updates the upper bound of the spike detector slider

function  updateSpikePromSlider(self,src,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% get the upper bound
ub = str2double(get(self.handles.prom_ub_control,'String'));
current_value = get(self.handles.spike_prom_slider,'Value');

if isnan(ub)
	return
end

if ub <= 0
	return
end

set(self.handles.spike_prom_slider,'Max',ub);
set(self.handles.spike_prom_slider,'Min',ub/100);
self.handles.spike_prom_slider.Value = ub;


if src == self.handles.spike_prom_slider
	self.findSpikes;
end