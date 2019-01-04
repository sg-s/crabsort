%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% modifies data based on mouse clicks 
function modify(self,p)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


channel = self.channel_to_work_with;
if self.channel_stage(channel) < 3
    return
end



% figure out wheter we are right or left clicking
switch self.handles.main_fig.SelectionType
case 'normal'
    self.leftClickCallback(p);
case 'alt'
    self.rightClickCallback(p);
otherwise
    error('Unknown mouse action')
end

% if self.handles.mode_new_spike.Value == 1
%     % snip out a small waveform around the point

%     % need to update the spike sign control to match automate info, if it exists
%     self.updateSettingsFromNNdata(); 

%     if ~self.handles.spike_sign_control.Value
%         [~,loc] = min(V(floor(p(1)-search_width:p(1)+search_width)));
%     else
%         [~,loc] = max(V(floor(p(1)-search_width:p(1)+search_width)));
%     end

%     new_spike = floor(loc + p(1) - search_width) - 1;

%     % which neuron are we adding to
%     S = self.handles.new_spike_type.String;
%     if iscell(S)
%         S = S{self.handles.new_spike_type.Value};
%     end

%     self.spikes.(this_nerve).(S) = sort([self.spikes.(this_nerve).(S); new_spike]);

%      % update the NNdata by appending this to the NNdata
%     NNdata = self.common.NNdata(channel);

%     self.putative_spikes(:,channel) = 0;
%     self.putative_spikes(new_spike,channel) = 1;
%     self.getDataToReduce;
%     NNdata.raw_data = [NNdata.raw_data self.data_to_reduce];
%     NNdata.file_idx(end+1) = self.getFileSequence;
%     NNdata.spiketimes(end+1) = new_spike;
%     NNdata.label_idx(end+1) = find(strcmp(self.handles.new_spike_type.String,S)); 
%     NNdata.check()
%     self.putative_spikes(:,channel) = 0;
   

%     self.common.NNdata(channel) = NNdata;
    

%     self.showSpikes;
    
% % elseif self.handles.mode_delete_spike.Value == 1

% %     self.updateSettingsFromNNdata(); 

% %     % get all spikes on this nerve
% %     [spiketimes, st_by_unit] = self.getSpikesOnThisNerve;
% %     spiketimes = find(spiketimes);
% %     % find the closest spike
% %     D = (((spiketimes-p(1))/(xrange)).^2  + ((V(spiketimes) - p(2))/(5*yrange)).^2);

% %     [~,idx] = min(D);

% %     % go through every neuron on this channel and wipe this spike 
% %     fn = fieldnames(self.spikes.(this_nerve));
% %     for i = 1:length(fn)
% %         self.spikes.(this_nerve).(fn{i}) = setdiff(self.spikes.(this_nerve).(fn{i}),spiketimes(idx));
% %     end

% %     % update the NNdata by updating the labels of these to noise
% %     NNdata = self.common.NNdata(channel);
% %     rm_this = NNdata.spiketimes == (spiketimes(idx)) & NNdata.file_idx == self.getFileSequence;
% %     if any(rm_this)
% %         NNdata.label_idx(rm_this) = 0;
% %     else
% %         % the deleted spike does not exist in the training
% %         % data, so it needs to be added and marked as noise 

% %         self.putative_spikes(:,channel) = 0;
% %         self.putative_spikes(spiketimes(idx),channel) = 1;
% %         self.getDataToReduce;
% %         NNdata.raw_data = [NNdata.raw_data self.data_to_reduce];
% %         NNdata.file_idx(end+1) = self.getFileSequence;
% %         NNdata.spiketimes(end+1) = spiketimes(idx);
% %         NNdata.label_idx(end+1) = 0; 
% %         NNdata.check()

% %         self.putative_spikes(:,channel) = 0;
% %     end

% %     self.common.NNdata(channel) = NNdata;

% %     self.showSpikes;

% elseif self.handles.mode_off.Value == 1
%     % don't do anything


% end



