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
function loadFile_CRAB(self,~,~)



% read the file
load(joinPath(self.path_name,self.file_name),'-mat');

% populate builtin_channel_names
self.builtin_channel_names = builtin_channel_names;
self.metadata = metadata;
self.raw_data = raw_data;
self.dt = dt;
self.n_channels = size(self.raw_data,2);
self.time = (1:length(self.raw_data))*dt;
