%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%

function showHideChannels(self,src,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


channel = find(strcmp(self.builtin_channel_names,src.Text));

if strcmp(src.Checked,'on')
	src.Checked = 'off';
	self.common.show_hide_channels(channel) = false;
	if channel  == self.channel_to_work_with
		self.channel_to_work_with = [];
	end
else
	src.Checked = 'on';
	self.common.show_hide_channels(channel) = true;
end

self.showHideAxes;

