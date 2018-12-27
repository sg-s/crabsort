%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% updates various elements when a new channel is selected


function updateControlsOnChannelChange(self)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


if ~isfield(self.handles,'ax')
	return
end

if isempty(self.pref)
    return
end

value = self.channel_to_work_with;


% highlight the currently chosen channel
for i = 1:length(self.handles.ax.ax)

    self.handles.ax.ax(i).YColor = 'k';
    self.handles.ax.channel_label_chooser(i).ForegroundColor = [0 0 0];

end

if ~isempty(value)

    self.handles.ax.ax(value).YColor = 'r';
    self.handles.ax.channel_label_chooser(value).ForegroundColor = [1 0 0];
    self.handles.ax.ax(value).GridColor = [.15 .15 .15];
end

c = lines;

if isempty(value)
    % no channel chosen, show all channels
    for i = 1:length(self.handles.ax.ax)
        self.handles.ax.data(i).Color = c(i,:);
    end
else
    % make all other channels desaturated
    c = lines;
    for i = 1:length(self.handles.ax.ax)
        self.handles.ax.data(i).Color = [.5 .5 .5];
    end
    self.handles.ax.data(value).Color = c(value,:);
end

% disable allowing automation on this channel
disableMenuItem(vertcat(self.handles.menu_name.Children),'Text','Run on this channel');

% if the name for this channel is unset, disable
% everything
if isempty(value)
    return
end

if length(self.common.data_channel_names) < self.channel_to_work_with || strcmp(self.common.data_channel_names{self.channel_to_work_with},'???') || isempty(self.common.data_channel_names{self.channel_to_work_with})

    if self.verbosity > 5
        cprintf('green','\n[INFO] ')
        cprintf('text','the name for this channel is unset')
    end

    %  
    % disable everything and force user to name the channel

    % disable everything
    disable(self.handles.spike_detection_panel);
    disable(self.handles.dim_red_panel);
    disable(self.handles.cluster_panel);


else

    if self.verbosity > 5
        cprintf('green','\n[INFO] ')
        cprintf('text','This channel is named')
    end

    % lots of possibilities here 
    % enable everything
    enable(self.handles.spike_detection_panel);
    enable(self.handles.dim_red_panel);
    enable(self.handles.cluster_panel);

    % if it's intracellular
    temp = isstrprop(self.common.data_channel_names{value},'upper');
    if any(temp)
        new_max = diff(self.handles.ax.ax(value).YLim)/2;
        self.handles.prom_ub_control.String = mat2str(new_max);
        self.handles.spike_prom_slider.Max = new_max;
        self.handles.spike_prom_slider.Value = new_max;
    else
        % use custom Y-lims if we have it --
        % unless it's an intracellular channel, in which case
        % we ignore it
        if ~isempty(self.channel_ylims) && ~isempty(self.channel_ylims(value)) && self.channel_ylims(value) > 0
            yl = self.channel_ylims(value);
            self.handles.ax.ax(value).YLim = [-yl yl];
        end
    end

    
end

% reset the manual_override to off
self.handles.mode_off.Value = 1;

% if this channel has sorted spike, enable the manual override 
if self.channel_stage(self.channel_to_work_with) > 2
    enable(self.handles.manual_panel)

    % update the neuron names if extracellular
    temp = isstrprop(self.common.data_channel_names{self.channel_to_work_with},'upper');
    if ~any(temp)
        neuron_names = self.nerve2neuron.(self.common.data_channel_names{self.channel_to_work_with});
        self.handles.new_spike_type.String = neuron_names;
    else
        self.handles.new_spike_type.String = self.common.data_channel_names{self.channel_to_work_with};
    end
    
else
    disable(self.handles.manual_panel)
end

% if this channel has a neural network associated with it, show it
self.NNmakeCheckpointDirs()

network_loc = [self.path_name 'network' filesep self.common.data_channel_names{self.channel_to_work_with} filesep 'trained_network.mat'];


if exist(network_loc,'file') == 2
    load(network_loc,'info');
    ValidationAccuracy = info.ValidationAccuracy(end);
    self.handles.nn_accuracy.String = oval(ValidationAccuracy,3);
    self.handles.nn_status.String = 'IDLE';
else
    self.handles.nn_accuracy.String = 'N/A';
    self.handles.nn_status.String = 'NO NET';
end