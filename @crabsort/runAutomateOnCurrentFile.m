%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%

function runAutomateOnCurrentFile(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if isempty(self.raw_data)
	return
end

for j = self.common.automate_channel_order
	if isempty(self.common.automate_info(j).operation)
		continue
	end

	% switch to the correct channel
	self.channel_to_work_with = j;

	self.runAutomateOnCurrentChannel;
end
self.saveData;