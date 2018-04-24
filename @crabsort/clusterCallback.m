%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% callback when cluster is called
% this calls other plugins that handle
% the actual clustering 

function clusterCallback(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

channel = self.channel_to_work_with;

cluster_method_handle = (get(self.handles.cluster_control,'Value'));
temp = get(self.handles.cluster_control,'String');
cluster_method_handle = temp{cluster_method_handle};
cluster_method_handle = str2func(cluster_method_handle);

% append to automate info before we run the method
% so that the method can modify/add to this if it wants to

if self.watch_me && ~self.automatic

    operation = struct;
    operation.property = {{'cluster_control'}};
    operation.value = {self.handles.cluster_control.String{self.handles.cluster_control.Value}};
    operation.method = @clusterCallback;
    operation.data = [];

    self.common.automate_info(channel).operation(end+1) = operation;

end


cluster_method_handle(self);
self.channel_stage(channel) = 3; 
 
self.showSpikes;

temp = self.getSpikesOnThisNerve;
self.putative_spikes(:,channel) = temp;


% hide all the putative spikes
self.handles.ax.found_spikes(channel).XData = NaN;
self.handles.ax.found_spikes(channel).YData = NaN;

if self.watch_me && ~self.automatic
	% show that we have automate info, if we do
	self.handles.ax.has_automate(channel).Visible = 'on';
end

% show the modify controls
enable(self.handles.manual_panel)

self.handles.main_fig.Name = [self.file_name '  -- Clustering complete using ' func2str(cluster_method_handle)]

% now lock the channel names on this channel and prevent the user from ever renaming it
if ~isfield(self.common,'channel_name_lock')
    self.common.channel_name_lock = zeros(self.n_channels,1);
end
self.common.channel_name_lock(self.channel_to_work_with) = 1;

self.handles.ax.channel_label_chooser(self.channel_to_work_with).Enable = 'off';