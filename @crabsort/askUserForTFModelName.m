%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% asks the user for a name for tensorflow model
% 

function askUserForTFModelName(self)


self.handles.tf_dialog = dialog('Position',[300 300 600 300],'Name','Pick name for TF model');

self.handles.tf_model_name = uicontrol(self.handles.tf_dialog,'units','normalized','Position',[.15 .65 .6 .3],'Style','edit','String','Enter Name','FontSize',self.pref.fs,'Callback',@self.setTFModelName);

uiwait(self.handles.tf_dialog)