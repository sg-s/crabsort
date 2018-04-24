%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% 

function updateTFChannel(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

this_channel = self.handles.tf.channel_picker.String{self.handles.tf.channel_picker.Value};


% reset all values to 1 before updating strings
self.handles.tf.available_data.Value = 1;
self.handles.tf.train_data.Value = 1;

% update strings
self.handles.tf.available_data.String = {};
self.handles.tf.train_data.String = {};

% reset the accuracy plot
self.handles.tf.accuracy_plot.XData = NaN;
self.handles.tf.accuracy_plot.YData = NaN;

if strcmp(this_channel,'Choose channel with spikes...')
	% disable everything
	self.handles.tf.reset_training.Enable = 'off';
	self.handles.tf.train_button.Enable = 'off';
	self.handles.tf.unload_data.Enable = 'off';
	self.handles.tf.load_data.Enable = 'off';
	self.handles.tf.reset_network_button.Enable = 'off';
	return
end

S = getFilesWithSortedSpikesOnChannel(self,this_channel);

self.handles.tf.available_data.String = S;

% enable stuff
self.handles.tf.reset_training.Enable = 'on';
self.handles.tf.load_data.Enable = 'on';
self.handles.tf.reset_network_button.Enable = 'on';
self.handles.tf.available_data.Enable = 'on';

% do we already have some training info for this channel?
% if so, load it
value = find(strcmp(self.common.data_channel_names,this_channel));

if ~isfield(self.common,'tf') || ~isfield(self.common.tf,'metrics') || length(self.common.tf.metrics) < value
	return
end

if isempty(self.common.tf.metrics(value))
	return
end

self.handles.tf.accuracy_plot.XData = self.common.tf.metrics(value).nsteps;
self.handles.tf.accuracy_plot.YData = 1 - self.common.tf.metrics(value).accuracy;
if max(self.common.tf.metrics(value).nsteps) > 0
	self.handles.tf.accuracy_ax.XLim = [0 max(self.common.tf.metrics(value).nsteps)];
end

