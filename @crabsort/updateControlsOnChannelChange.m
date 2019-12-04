%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% updates various elements when a new channel is selected


function updateControlsOnChannelChange(self)

c = lines;

if ~isfield(self.handles,'ax')
	return
end

if isempty(self.pref)
    return
end


channel = self.channel_to_work_with;


% highlight the currently chosen channel
for i = 1:length(self.handles.ax.ax)
    self.handles.ax.ax(i).YColor = 'k';
    self.handles.ax.channel_label_chooser(i).ForegroundColor = [0 0 0];
end


if isempty(channel)
    % no channel selected, exit early
    % no channel chosen, show all channels
    for i = 1:length(self.handles.ax.ax)
        self.handles.ax.data(i).Color = c(i,:);
    end
    return
end


% some channel selected
self.handles.ax.ax(channel).YColor = 'r';
self.handles.ax.channel_label_chooser(channel).ForegroundColor = [1 0 0];
self.handles.ax.ax(channel).GridColor = [.15 .15 .15];


% make all other channels desaturated
for i = 1:length(self.handles.ax.ax)
    self.handles.ax.data(i).Color = [.5 .5 .5];
end
self.handles.ax.data(channel).Color = c(channel,:);

if isempty(self.common.data_channel_names{channel})
    % unnamed channel. early exit
    uxlib.disable(self.handles.spike_detection_panel)
    uxlib.disable(self.handles.dim_red_panel)
    uxlib.disable(self.handles.cluster_panel)
    uxlib.disable(self.handles.mask_panel)
    uxlib.disable(self.handles.manual_panel)
    return
end



% OK, we have a named channel
% trigger the correct mode by resetting channel_stage
self.channel_stage(channel) = self.channel_stage(channel);


% update the manual control add to menu
self.handles.new_spike_type.String = self.getNeuronsOnThisNerve;
self.handles.new_spike_type.Value = 1;


warning('off','MATLAB:gui:array:InvalidArrayShape')
drawnow;
warning('on','MATLAB:gui:array:InvalidArrayShape')
