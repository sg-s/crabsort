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

% append to automate info before we run the method
% so that the method can modify/add to this if it wants to

if self.watch_me && ~self.automatic

    operation = struct;
    operation.property = {{'cluster_control'}};
    operation.value = {self.handles.cluster_control.String{self.handles.method_control.Value}};
    operation.method = @clusterCallback;
    operation.data = [];

    self.common.automate_info(self.channel_to_work_with).operation(end+1) = operation;

end


cluster_method_handle(self);
self.channel_stage(self.channel_to_work_with) = 3; 
 
self.showSpikes;

temp = self.getSpikesOnThisNerve;
self.putative_spikes(:,self.channel_to_work_with) = temp;



