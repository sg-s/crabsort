%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% callback when channel_label_picker is used

function updateChannel(self, src, value)

idx = find(self.handles.channel_label_chooser == src);

self.common.data_channel_names{idx} = src.String{src.Value};
