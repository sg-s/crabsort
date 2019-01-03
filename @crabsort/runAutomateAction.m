
function runAutomateAction(self)


switch self.automate_action
case crabsort.automateAction.all_channels_all_files
	keyboard
case crabsort.automateAction.all_channels_this_file
	for channel = 1:self.n_channels
		if self.automate_action == crabsort.automateAction.none
			% action cancelled
			self.auto_predict = true;
			if strcmp(self.timer_handle.Running,'off')
				start(self.timer_handle)
			end
			break
		end


		self.channel_to_work_with = channel;

		if self.channel_stage(channel) == 0
			if isempty(self.common.NNdata(channel).other_nerves_control)
				continue
			end
			% put logic here
			self.NNpredict;
			self.showSpikes;
			pause(1)
		end

	end
	self.automate_action = crabsort.automateAction.none;
	start(self.timer_handle)
	self.auto_predict = true;

case crabsort.automateAction.this_channel_all_files
	if isempty(self.channel_to_work_with)
		% nothing to do, so restart the timer
		start(self.timer_handle)
		return
	else
		channel = self.channel_to_work_with;
	end

	% go over all the files and load them
	[~,~,ext]=fileparts(self.file_name);
	allfiles = (dir([self.path_name '*' ext]));
	for i = 1:length(allfiles)

		if self.automate_action == crabsort.automateAction.none
			% action cancelled
			self.auto_predict = true;
			if strcmp(self.timer_handle.Running,'off')
				start(self.timer_handle)
			end
			break
		end

		% simulate a next file button press
		temp = struct();
		temp.String = '>';
		self.loadFile(temp)

		self.channel_to_work_with = channel;

		if self.channel_stage(channel) == 0
			% put logic here
			self.NNpredict;
			self.showSpikes;
			pause(1)
		end
	end

	self.automate_action = crabsort.automateAction.none;
	start(self.timer_handle)
	self.auto_predict = true;

	

end