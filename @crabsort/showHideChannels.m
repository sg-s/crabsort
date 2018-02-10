%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%

function showHideChannels(self,src,~)

channel = find(self.handles.menu_name(5).Children == src);

if strcmp(src.Checked,'on')
	src.Checked = 'off';
	self.common.show_hide_channels{channel} = 'off';
	if channel  == self.channel_to_work_with
		self.channel_to_work_with = [];
	end
else
	src.Checked = 'on';
	self.common.show_hide_channels{channel} = 'on';
end

self.redrawAxes(true);
self.showSpikes;

