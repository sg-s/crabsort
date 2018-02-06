%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% 

function updateTFChannel(self,src,~)

this_channel = self.handles.tf.channel_picker.String{self.handles.tf.channel_picker.Value};

S = getFilesWithSortedSpikesOnChannel(self,this_channel);

% reset all values to 1 before updating strings
self.handles.tf.available_data.Value = 1;
self.handles.tf.train_data.Value = 1;

% update strings
self.handles.tf.available_data.String = S;
self.handles.tf.train_data.String = {};