%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% updates various elements when a new channel is selected


function updateControlsOnChannelChange(self)

if ~isfield(self.handles,'ax')
	return
end

value = self.channel_to_work_with;

% use custom Y-lims if we have it
if ~isempty(self.channel_ylims) && ~isempty(self.channel_ylims(value)) && self.channel_ylims(value) > 0
    yl = self.channel_ylims(value);
    self.handles.ax(value).YLim = [-yl yl];
end


% highlight the currently chosen channel
for i = 1:length(self.handles.ax)
    self.handles.ax(i).YColor = 'k';
    self.handles.ax(i).LineWidth = 1;
end
self.handles.ax(value).YColor = 'r';
self.handles.ax(value).LineWidth = 3;


% disable allowing automation on this channel
disableMenuItem(vertcat(self.handles.menu_name.Children),'Text','Run on this channel');

% if the name for this channel is unset, disable
% everything
if length(self.common.data_channel_names) < self.channel_to_work_with || strcmp(self.common.data_channel_names{self.channel_to_work_with},'???') || isempty(self.common.data_channel_names{self.channel_to_work_with})
    % disable everything
    self.disable(self.handles.spike_detection_panel);
    self.disable(self.handles.dim_red_panel);
    self.disable(self.handles.cluster_panel);


else
    % enable everything
    self.enable(self.handles.spike_detection_panel);
    self.enable(self.handles.dim_red_panel);
    self.enable(self.handles.cluster_panel);

    % if it's intracellular
    temp = isstrprop(self.common.data_channel_names{value},'upper');
    if any(temp)
        new_max = diff(self.handles.ax(value).YLim)/2;
        self.handles.prom_ub_control.String = mat2str(new_max);
        self.handles.spike_prom_slider.Max = new_max;
        self.handles.spike_prom_slider.Value = new_max;
    end

    % if this channel has automate_info
    % enable automation on this channel 

    if length(self.common.automate_info) >= self.channel_to_work_with && ~isempty(self.common.automate_info(self.channel_to_work_with).operation)

        enableMenuItem(vertcat(self.handles.menu_name.Children),'Text','Run on this channel');
        enableMenuItem(vertcat(self.handles.menu_name.Children),'Text','Delete automate info for this channel');
    else
        disableMenuItem(vertcat(self.handles.menu_name.Children),'Text','Run on this channel');
        disableMenuItem(vertcat(self.handles.menu_name.Children),'Text','Delete automate info for this channel');
    end


    % if the channel has sorted spikes, enable training
    % s = self.getSpikesOnThisNerve;
    % if any(s)
    %     % enable training
    %     self.handles.menu_name(4).Children(4).Enable = 'on';
    %     % do we already have a model trained?
    %     if length(self.common.tf_model_name) < self.channel_to_work_with  || isempty(self.common.tf_model_name{self.channel_to_work_with})
    %         self.handles.menu_name(4).Children(4).Text = 'Train network';
    %     else
    %         % we already have a model
    %         self.handles.menu_name(4).Children(4).Text = 'Retrain network';
    %     end

    % else
    %     % disable training
    %     self.handles.menu_name(4).Children(4).Enable = 'off';

    %     if length(self.common.tf_model_name) < self.channel_to_work_with || isempty(self.common.tf_model_name{self.channel_to_work_with})
    %         % disable prediction
    %         self.handles.menu_name(4).Children(3).Enable = 'off';
    %     else
    %         % we already have a model
    %         self.handles.menu_name(4).Children(3).Enable = 'on';
    %     end

    % end

end

% reset the manual_override to off
self.handles.mode_off.Value = 1;

% if this channel has sorted spike, enable the manual override 
if self.channel_stage(self.channel_to_work_with) > 2
    self.enable(self.handles.manual_panel)

    % update the neuron names
    neuron_names = self.nerve2neuron.(self.common.data_channel_names{self.channel_to_work_with});
    self.handles.new_spike_type.String = neuron_names;
else
    self.disable(self.handles.manual_panel)
end