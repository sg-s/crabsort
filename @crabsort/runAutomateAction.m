
function runAutomateAction(self)

menu_items = self.handles.menu_name(4).Children;


% go over all the files and load them
[~,~,ext] = fileparts(self.file_name);
allfiles = dir([self.path_name '*' ext]);
n_files = length(allfiles);

switch self.automate_action

case crabsort.automateAction.view_only
		
	channel = self.channel_to_work_with;

	for i = 1:n_files

		if self.shouldAutomateStop(channel)
			beep
			self.auto_predict = true;
			break
		end

		self.loadFile(self.handles.next_file_control)

		drawnow;
	end

	self.automate_action = crabsort.automateAction.none;
	if strcmp(self.timer_handle.Running,'off')
		start(self.timer_handle)
	end
	self.auto_predict = true;


case crabsort.automateAction.all_channels_all_files
	

	for i = 1:n_files

		if self.shouldAutomateStop
			beep
			self.auto_predict = true;
			break
		end

		% simulate a next file button press
		self.loadFile(handles.next_file_control)

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

			if strcmp(menu_items(find(strcmp({menu_items.Text},'Overwrite previous predictions'))).Checked,'on')
				self.redo;
			end

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

		if strcmp(menu_items(find(strcmp({menu_items.Text},'Overwrite previous predictions'))).Checked,'on')
			self.redo;
		end

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


	for i = 1:n_files

		if self.shouldAutomateStop
			beep
			self.auto_predict = true;
			break
		end


		% does this file have a .crabsort file, and
		% are the channels sorted there? 

		if strcmp(menu_items(find(strcmp({menu_items.Text},'Overwrite previous predictions'))).Checked,'on')
			% just load the next file
			self.loadFile(self.handles.next_file_control)
		else
			% we can skip if needed
			% find the next data file that doesn't have spikes on this channel
			should_stop = self.loadNextUnsortedFile();

			if should_stop 
				beep
				self.auto_predict = true;
				break
			end

		end


		self.channel_to_work_with = channel;


		if strcmp(menu_items(find(strcmp({menu_items.Text},'Overwrite previous predictions'))).Checked,'on')
			self.redo;

		end


		if self.channel_stage(channel) == 0 
			% put logic here

			if strcmp(menu_items(find(strcmp({menu_items.Text},'mark data outside YLim as artifacts'))).Checked,'on')
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