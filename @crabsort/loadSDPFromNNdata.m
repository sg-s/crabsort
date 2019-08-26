% loadSDPFromNNdata
% load spike detection parameters 
% from NNdata

function loadSDPFromNNdata(self, futz_factor)

if self.verbosity > 9
	disp(mfilename)
end

channel = self.channel_to_work_with;

if nargin == 1
	futz_factor = 1;
end

if isempty(channel)
	disp('No channel selected')
	return
end



% update settings from NNdata
self.sdp = self.common.NNdata(channel).sdp;


if self.sdp.spike_sign
	set(self.handles.spike_sign_control,'String','+ve spikes')
	self.handles.spike_sign_control.Value = 1;
else
	set(self.handles.spike_sign_control,'String','-ve spikes')
	self.handles.spike_sign_control.Value = 0;
end

% futz with some parameters
self.sdp.MinPeakProminence = self.sdp.MinPeakProminence*futz_factor;

if ~self.isIntracellular(channel)
	self.sdp.MinPeakHeight = self.sdp.MinPeakHeight*futz_factor;
end



self.handles.multi_channel_control.Value = self.common.NNdata(channel).other_nerves_control;
self.handles.multi_channel_control_text.String = self.common.NNdata(channel).other_nerves;
