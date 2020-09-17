% saveSDPToNNdata
% saves spike detection parameters from
% crabsort into NNdata 

function saveSDPToNNdata(self)

channel = self.channel_to_work_with;


if isempty(channel)
	disp('No channel selected')
	return
end



if self.common.NNdata(channel).sdp.isdefault

	% we write to NNdata only if it has default values. this guarantees
	% that we cannot overwrite it accidentally 

	self.common.NNdata(channel).sdp = self.sdp;
	self.common.NNdata(channel).other_nerves_control = logical(self.handles.multi_channel_control.Value);
	self.common.NNdata(channel).other_nerves = self.handles.multi_channel_control_text.String;

else
	warning('Not writing to NNdata to avoid overwriting data')
end

