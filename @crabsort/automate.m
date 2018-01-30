%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% attempts to go through all files and run through
% the process that was done earlier manually 

function automate(self,src,~)


% early exit
if isempty(self.common.automate_info)
	disp('No automate info, nothing to do')
	return
end

self.automatic = true;

% figure out what to do based on the src

switch src.Text
case 'Run on this channel'
	self.runAutomateOnCurrentChannel;
case 'Run on this file'
	self.runAutomateOnCurrentFile;
case 'Run on all files...'
	self.runAutomateOnAllFiles;
otherwise
	self.automatic = false;
	error('[001] Unknown src for automate')
end

self.automatic = false;