%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% attempts to go through all files and run through
% the process that was done earlier manually 

function automate(self,src,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end

% early exit
if isempty(self.common.automate_info)
	disp('No automate info, nothing to do')
	return
end

self.saveData;

self.automatic = true;

% figure out what to do based on the src

switch src.Text
case 'Run on this channel'
	self.runAutomateOnCurrentChannel;
case 'Run on this file'

	% make sure that every channel that 
	% automate is going to run on is visible
	if any(~self.common.show_hide_channels(self.common.automate_channel_order))
		for i = self.common.automate_channel_order
			self.common.show_hide_channels(i) = true;
		end
		self.showHideAxes;
		self.showSpikes;
	end
	self.runAutomateOnCurrentFile;
case 'Run on all files...'
	% make sure that every channel that 
	% automate is going to run on is visible
	if any(~self.common.show_hide_channels(self.common.automate_channel_order))
		for i = self.common.automate_channel_order
			self.common.show_hide_channels(i) = true;
		end
		self.showHideAxes;
		self.showSpikes;
	end
	self.runAutomateOnAllFiles;
otherwise
	self.automatic = false;
	error('[001] Unknown src for automate')
end

self.automatic = false;

self.handles.main_fig.Name = [self.file_name '  -- Automate has finished running.']