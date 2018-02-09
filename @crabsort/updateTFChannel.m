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

% do we already have some training info for this channel?
% if so, load it
value = find(strcmp(self.common.data_channel_names,this_channel));

if ~isfield(self.common.tf,'metrics') || length(self.common.tf.metrics) < value
	return
end

if isempty(self.common.tf.metrics(value))
	return
end

self.handles.tf.accuracy_plot.XData = self.common.tf.metrics(value).nsteps;
self.handles.tf.accuracy_plot.YData = 1 - self.common.tf.metrics(value).accuracy;
self.handles.tf.accuracy_ax.XLim = [0 max(self.common.tf.metrics(value).nsteps)];