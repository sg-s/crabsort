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

switch src.Text
case 'Delete ALL automate info'
	self.common.automate_info = [];
	self.common.automate_channel_order = [];

case 'Delete automate info for this channel'
	self.common.automate_info(self.channel_to_work_with) = [];
	self.common.automate_channel_order = setdiff(self.common.automate_channel_order, self.channel_to_work_with);
otherwise
	error('[#345] Unrecognised source of delete all automate info. Dont know what to do, so will default to doing nothing ')

end