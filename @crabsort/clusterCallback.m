% master dispatched when we want to cluster the data

function clusterCallback(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

cluster_method_handle = (get(s.handles.cluster_control,'Value'));
temp = get(s.handles.cluster_control,'String');
cluster_method_handle = temp{cluster_method_handle};
cluster_method_handle = str2func(cluster_method_handle);

cluster_method_handle(s);
 
s.removeDoublets;
 