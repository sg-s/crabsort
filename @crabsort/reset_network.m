%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% 
% resets tensorflow state, throwas away all accumulated data
% discards the network
function reset_network(self,~,~)

this_channel = self.handles.tf.channel_picker.String{self.handles.tf.channel_picker.Value};
idx = find(strcmp(self.common.data_channel_names,this_channel));
if strcmp(this_channel,'Choose channel with spikes...')
	return
end

self.common.tf.metrics(idx).nsteps = [];
self.common.tf.metrics(idx).accuracy = [];

% wipe data from the accuracy ax
self.handles.tf.accuracy_plot.XData = NaN;
self.handles.tf.accuracy_plot.YData = NaN;

% delete Tensorflow model and other files 
% delete everything except .py files, and .mat files 
tf_model_dir = joinPath(self.path_name,'tensorflow',this_channel);
allfiles = getAllFiles(tf_model_dir);

for i = 1:length(allfiles)
	[~,~,ext] = fileparts(allfiles{i});
	if strcmp(ext,'.py') || strcmp(ext,'.mat')
		continue
	end
	delete(allfiles{i})
end