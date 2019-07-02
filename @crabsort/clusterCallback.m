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


channel = self.channel_to_work_with;

cluster_func_handle = str2func(['csCluster.' self.handles.cluster_control.String{self.handles.cluster_control.Value}]);

self = cluster_func_handle(self);

self.channel_stage(channel) = 3; 
 
self.showSpikes(channel);

temp = self.getSpikesOnThisNerve;
self.putative_spikes(:,channel) = temp;


% hide all the putative spikes
self.handles.ax.found_spikes(channel).XData = NaN;
self.handles.ax.found_spikes(channel).YData = NaN;


self.handles.main_fig.Name = [self.file_name '  -- Clustering complete using ' func2str(cluster_func_handle)];

% now lock the channel names on this channel and prevent the user from ever renaming it
self.common.channel_name_lock(self.channel_to_work_with) = true;
self.handles.ax.channel_label_chooser(self.channel_to_work_with).Enable = 'off';

