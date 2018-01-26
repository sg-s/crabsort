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

function deleteAllAutomateInfo(self,~,~)

self.automate_info = [];
self.automate_channel_order = [];
