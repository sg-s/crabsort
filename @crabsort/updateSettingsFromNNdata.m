
function updateSettingsFromNNdata(self, spike_prom_futz_factor)

channel = self.channel_to_work_with;

if nargin == 1
	spike_prom_futz_factor = 1;
end

if isempty(channel)
	disp('No channel selected')
	return
end

% use automate info to update this stuff
NNdata = self.common.NNdata(channel);
self.handles.spike_prom_slider.Max = NNdata.spike_prom*spike_prom_futz_factor;
self.handles.spike_prom_slider.Value = NNdata.spike_prom*spike_prom_futz_factor;
self.handles.spike_sign_control.Value = NNdata.spike_sign;
self.handles.multi_channel_control_text.String  = NNdata.other_nerves;
self.handles.multi_channel_control.Value = NNdata.other_nerves_control;
