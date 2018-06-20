%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% callback when channel_label_picker is used

function updateChannel(self, src, ~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


idx = find(self.handles.ax.channel_label_chooser == src);

% check that the user hasn't picked an already
% used name 

if any(strcmp(self.common.data_channel_names,src.String{src.Value}))
	
	% is the user simply picking the same thing?
	if strcmp(self.common.data_channel_names{idx},src.String{src.Value})
		% do nothing
		return
	else
		% fuck
		src.Value = 1;

		% throw an error
		error('[ERROR] You cannot have two channels with the same name.')
	end
else

	self.common.data_channel_names{idx} = src.String{src.Value};

	self.channel_to_work_with = idx;
	self.removeMean(idx);
end


if strcmp(self.common.data_channel_names{idx},'temperature')
	self.handles.ax.ax(idx).YLim = [5 35];
	self.handles.ax.ax(idx).YTickMode = 'auto';
end