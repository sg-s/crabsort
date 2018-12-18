
function updateSettingsFromAutomateInfo(self)

channel = self.channel_to_work_with;

if isempty(channel)
	disp('No channel selected')
	return
end

% use automate info to update this stuff
self.handles.spike_prom_slider.Max = self.common.automate_info(channel).spike_prom;
self.handles.spike_prom_slider.Value = self.common.automate_info(channel).spike_prom;
self.handles.spike_sign_control.Value = self.common.automate_info(channel).spike_sign;
self.handles.multi_channel_control_text.String  = self.common.automate_info(channel).other_nerves;
self.handles.multi_channel_control.Value = self.common.automate_info(channel).other_nerves_control;
