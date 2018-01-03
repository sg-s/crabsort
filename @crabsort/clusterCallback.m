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

cluster_method_handle = (get(self.handles.cluster_control,'Value'));
temp = get(self.handles.cluster_control,'String');
cluster_method_handle = temp{cluster_method_handle};
cluster_method_handle = str2func(cluster_method_handle);

cluster_method_handle(self);

self.channel_stage(self.channel_to_work_with) = 3; 
 

self.showSpikes;

temp = self.getSpikesOnThisNerve;
self.putative_spikes(:,self.channel_to_work_with) = temp;
