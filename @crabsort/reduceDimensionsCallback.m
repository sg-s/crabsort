% master dispatched when we want to reduce dimensions

function reduceDimensionsCallback(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    d = dbstack;
    cprintf('text',[mfilename ' called by ' d(2).name])
end

method = (get(s.handles.method_control,'Value'));
temp = get(s.handles.method_control,'String');
method = temp{method};
method = str2func(method);

s.handles.popup.Visible = 'on';
s.handles.popup.String = {'','','','Reducing dimenisons...'};
drawnow;

method(s);

s.handles.popup.Visible = 'off';

% change the marker on the identified spikes
set(s.handles.ax1_all_spikes,'Marker','o','Color',s.pref.embedded_spike_colour,'LineStyle','none')
drawnow;

% disable the reduce dimensions callback
s.handles.method_control.Enable = 'off';