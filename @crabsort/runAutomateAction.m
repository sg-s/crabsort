
function runAutomateAction(self)



switch self.automate_action

case crabsort.automateAction.view_only
		

	channel = self.channel_to_work_with;

	% go over all the files and load them
	[~,~,ext]=fileparts(self.file_name);
	allfiles = (dir([self.path_name '*' ext]));
	for i = 1:length(allfiles)

		if self.shouldAutomateStop(channel)
			beep
			self.auto_predict = true;
			break
		end


		% % check if the next file is already sorted
		next_file = self.getFileSequence+1;
		if next_file > length(allfiles)
			next_file = 1;
		end


		self.file_name = allfiles(next_file).name;
		self.loadFile()


	end

	self.automate_action = crabsort.automateAction.none;
	if strcmp(self.timer_handle.Running,'off')
		start(self.timer_handle)
	end
	self.auto_predict = true;


case crabsort.automateAction.all_channels_all_files
	
	% go over all the files and load them
	[~,~,ext]=fileparts(self.file_name);
	allfiles = (dir([self.path_name '*' ext]));
	for i = 1:length(allfiles)

		if self.shouldAutomateStop
			beep
			self.auto_predict = true;
			break
		end

		% simulate a next file button press
		temp = struct();
		temp.String = '>';
		temp.Style = 'none';
		self.loadFile(temp)

		for channel = 1:self.n_channels

			if self.shouldAutomateStop
				beep
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
				self.showSpikes(channel);

				if self.shouldAutomateStop
					beep
					self.auto_predict = true;
					break
				end
					
			end

		end
	end

	self.automate_action = crabsort.automateAction.none;
	if strcmp(self.timer_handle.Running,'off')
		start(self.timer_handle)
	end
	self.auto_predict = true;



case crabsort.automateAction.all_channels_this_file
	for channel = 1:self.n_channels
		
		if self.shouldAutomateStop
			beep
			self.auto_predict = true;
			break
		end


		self.channel_to_work_with = channel;

		if self.channel_stage(channel) == 0
			if isempty(self.common.NNdata(channel).other_nerves_control)
				continue
			end
			% put logic here
			self.NNpredict;
			self.showSpikes(channel);
			pause(.1)
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

		if self.shouldAutomateStop
			beep
			self.auto_predict = true;
			break
		end


		% % check if the next file is already sorted
		next_file = self.getFileSequence+1;
		if next_file > length(allfiles)
			next_file = 1;
		end



		self.file_name = allfiles(next_file).name;
		self.loadFile()

		self.channel_to_work_with = channel;

		if self.channel_stage(channel) == 0
			% put logic here
			C = self.handles.menu_name(4).Children;
			if strcmp(C(find(strcmp({C.Text},'mark data outside YLim as artifacts'))).Checked,'on')
				% need to remove artifacts
				src.Text = 'Ignore sections where data exceeds Y bounds';
				self.ignoreSection(src);
			end
			self.NNpredict;
			self.showSpikes(channel);
			self.saveData;

			if self.shouldAutomateStop
				beep
				self.auto_predict = true;
				break
			end

			


		end
	end

	self.automate_action = crabsort.automateAction.none;
	if strcmp(self.timer_handle.Running,'off')
		start(self.timer_handle)
	end
	self.auto_predict = true;

	

end