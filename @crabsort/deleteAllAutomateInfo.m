%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
%
% deleteAllAutomateInfo.m
% part of the crabsort package
% deletes all automation info in current file

function deleteAllAutomateInfo(self,src,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end

switch src.Text
case 'Delete ALL automate info'
	self.common.automate_info = [];

	% delete all markers
	for i = 1:self.n_channels
		self.handles.ax.has_automate(i).BackgroundColor = [.9 .9 .9];
	end

case 'Delete automate info for this channel'
	self.common.automate_info(self.channel_to_work_with).spike_prom = [];
	self.common.automate_info(self.channel_to_work_with).spike_sign = [];
	self.common.automate_info(self.channel_to_work_with).other_nerves = {};
	self.common.automate_info(self.channel_to_work_with).other_nerves_control=[];

	% hide the marker
	self.handles.ax.has_automate(self.channel_to_work_with).Visible = 'off';

	% start watching
	obj = self.handles.menu_name(3).findobj('Text','Watch me');
	% simulate a mouse click
	self.updateWatchMe(obj)
otherwise
	error('[#345] Unrecognised source of delete all automate info. Dont know what to do, so will default to doing nothing ')

end
