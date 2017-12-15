%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% callback when channel_label_picker is used

function updateChannel(self, src, value)

idx = find(self.handles.channel_label_chooser == src);

self.data_channel_names{idx} = src.String{src.Value};

if strcmp(src.String{src.Value},'temperature')
	self.handles.ax(idx).YLim = [0 30];

end