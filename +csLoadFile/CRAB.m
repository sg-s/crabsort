% crabsort plugin
% plugin_type = 'load-file';
% data_extension = 'crab';
% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% 
function S = loadFile_CRAB(self,~,~)



% read the file
load(pathlib.join(self.path_name,self.file_name),'-mat');

% populate builtin_channel_names
S.builtin_channel_names = builtin_channel_names;
S.metadata = metadata;
S.raw_data = raw_data;
S.time = (1:length(raw_data))*dt;
