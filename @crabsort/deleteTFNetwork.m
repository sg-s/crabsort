%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% deletes the cached TF network file, if any 
% for the current channel
function deleteTFNetwork(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if length(self.tf_model_name) < self.channel_to_work_with
	return
end

try
	rmdir(joinPath(self.tf_folder,'models',self.tf_model_name{self.channel_to_work_with}),'s')
catch
end

% also unset the model name
self.tf_model_name{self.channel_to_work_with} = [];

% update the menu names
 self.handles.menu_name(4).Children(4).Text = 'Train network';
 self.handles.menu_name(4).Children(3).Enable = 'off';