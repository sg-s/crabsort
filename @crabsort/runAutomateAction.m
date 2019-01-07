
function runAutomateAction(self)


switch self.automate_action
case crabsort.automateAction.all_channels_all_files
	
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
		self.scroll([0 5])
		self.loadFile(temp)

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


				% check if we should stop if uncertain
				C = self.handles.menu_name(3).Children;
				if strcmp(C(strcmp({C.Text},'Stop when uncertain')).Checked,'on') & ~isempty(self.handles.ax.uncertain_spikes(channel).XData)
					disp('Stopping because I am uncertain')
					beep
					% action cancelled
					self.auto_predict = true;
					if strcmp(self.timer_handle.Running,'off')
						start(self.timer_handle)
					end
					break
				end
					
			end

		end
		pause(1)

	end

	self.automate_action = crabsort.automateAction.none;
	if strcmp(self.timer_handle.Running,'off')
		start(self.timer_handle)
	end
	self.auto_predict = true;



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
	if strcmp(self.timer_handle.Running,'off')
		start(self.timer_handle)
	end
	self.auto_predict = true;

case crabsort.automateAction.this_channel_all_files
	if isempty(self.channel_to_work_with)
		% nothing to do, so restart the timer
		self.automate_action = crabsort.automateAction.none;
		self.auto_predict = true;
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
		self.scroll([0 5])
		self.loadFile(temp)

		self.channel_to_work_with = channel;

		if self.channel_stage(channel) == 0
			% put logic here
			self.NNpredict;
			self.showSpikes;
			

			% check if we should stop if uncertain
			C = self.handles.menu_name(3).Children;
			if strcmp(C(strcmp({C.Text},'Stop when uncertain')).Checked,'on') & ~isempty(self.handles.ax.uncertain_spikes(channel).XData)
				disp('Stopping because I am uncertain')
				beep
				% action cancelled
				self.auto_predict = true;
				if strcmp(self.timer_handle.Running,'off')
					start(self.timer_handle)
				end
				break
			end

			pause(1)

		end
	end

	self.automate_action = crabsort.automateAction.none;
	if strcmp(self.timer_handle.Running,'off')
		start(self.timer_handle)
	end
	self.auto_predict = true;

	

end