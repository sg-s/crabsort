%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% throws away all data in the current channel
% and resets the state of this channel to 0

function redo(self,~,~)


if isempty(self.channel_to_work_with)
	return
end

if isfield(self.spikes,self.common.data_channel_names{self.channel_to_work_with})
	% remove this
	self.spikes = rmfield(self.spikes,self.common.data_channel_names{self.channel_to_work_with})
else
end

self.channel_stage(self.channel_to_work_with) = 0;

N = self.handles.ax.sorted_spikes(self.channel_to_work_with).unit;

for i = 1:length(N)
	N(i).YData = NaN;
	N(i).XData = NaN;
end

self.handles.main_fig.Name = [self.file_name ' -- Resetting data'];

self.showSpikes;
