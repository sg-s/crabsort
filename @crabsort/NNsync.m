% NNsync
% synchronizes spike detection parmeters
% between NNdata and crabsort
% if NNdata has no spike detection parameters,
% it is copied over from crabsort.spd
% if it does, then crabsort.spd is updated using NNdata 

function NNsync(self, futz_factor)

channel = self.channel_to_work_with;

if nargin == 1
	futz_factor = 1;
end

if isempty(channel)
	disp('No channel selected')
	return
end


if isempty(self.common.NNdata(channel).sdp.MinPeakProminence)
	% do the reverse operation -- update NNdata form settings
	self.common.NNdata(channel).sdp = self.sdp;
	self.common.NNdata(channel).other_nerves_control = logical(self.handles.multi_channel_control.Value);
	self.common.NNdata(channel).other_nerves = self.handles.multi_channel_control_text.String;


else
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
	self.sdp.MinPeakHeight = self.sdp.MinPeakHeight*futz_factor;


	self.handles.multi_channel_control.Value = self.common.NNdata(channel).other_nerves_control;
	self.handles.multi_channel_control_text.String = self.common.NNdata(channel).other_nerves;
end