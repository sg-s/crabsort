
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
		temp.Style = 'none';
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
				self.showSpikes(channel);


				% check if we should stop if uncertain
				C = self.handles.menu_name(3).Children;
				if strcmp(C(strcmp({C.Text},'Stop when uncertain')).Checked,'on') & ~isempty(self.handles.ax.uncertain_spikes(channel).XData)
					disp('Stopping because I am uncertain')
					beep
					self.jumpToNextUncertainSpike();
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
			self.showSpikes(channel);
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


		% % check if the next file is already sorted
		next_file = self.getFileSequence+1;
		if next_file > length(allfiles)
			next_file = 1;
		end

		% if exist([allfiles(next_file).name '.crabsort'],'file') == 2
		% 	load([allfiles(next_file).name '.crabsort'],'-mat')
		% 	if  crabsort_obj.channel_stage(channel) == 3
		% 		self.say(['Skipping ' allfiles(next_file).name])
		% 		continue
		% 	end

		% end


		self.file_name = allfiles(next_file).name;
		self.loadFile()

		self.channel_to_work_with = channel;

		if self.channel_stage(channel) == 0
			% put logic here
			self.NNpredict;
			self.showSpikes(channel);
			self.saveData;

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

	self.automate_action = crabsort.automateAction.none;
	if strcmp(self.timer_handle.Running,'off')
		start(self.timer_handle)
	end
	self.auto_predict = true;

	

end