%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% modifies data based on mouse clicks 
function modify(self,p)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

channel = self.channel_to_work_with;


ylimits = self.handles.ax(channel).YLim;
xlimits = self.handles.ax(channel).XLim;

xrange = (xlimits(2) - xlimits(1))/self.dt;
yrange = ylimits(2) - ylimits(1);

p(1) = p(1)/self.dt;

% get the width over which to search for spikes dynamically from the zoom factor
% search_width = floor((.005*xrange));

V = self.raw_data(:,channel);

% if get(self.handles.mode_new_A,'Value') == 1
%     % snip out a small waveform around the point
%     if s.pref.invert_V
%         [~,loc] = min(V(floor(p(1)-search_width:p(1)+search_width)));
%     else
%         [~,loc] = max(V(floor(p(1)-search_width:p(1)+search_width)));
%     end
%     A = [A; -search_width+loc+floor(p(1))];

% elseif get(s.handles.mode_new_B,'Value')==1
%     % snip out a small waveform around the point
%     if s.pref.invert_V
%         [~,loc] = min(V(floor(p(1)-search_width:p(1)+search_width)));
%     else
%         [~,loc] = max(V(floor(p(1)-search_width:p(1)+search_width)));
%     end
%     B = [B; -search_width+loc+floor(p(1))];

if self.handles.mode_delete_spike.Value == 1

    % get all spikes on this nerve
    [spiketimes, st_by_unit] = self.getSpikesOnThisNerve;
    spiketimes = find(spiketimes);
    % find the closest spike
    D = (((spiketimes-p(1))/(xrange)).^2  + ((V(spiketimes) - p(2))/(yrange)).^2);

    [~,idx] = min(D);

    % go through every neuron on this channel and wipe this spike 
    this_nerve = self.common.data_channel_names{channel};
    fn = fieldnames(self.spikes.(this_nerve));
    for i = 1:length(fn)
        self.spikes.(this_nerve).(fn{i}) = setdiff(self.spikes.(this_nerve).(fn{i}),spiketimes(idx));
    end

% elseif get(s.handles.mode_A2B,'Value') == 1 
% % find the closest B spike
%     dA = (((A-p(1))/(xrange)).^2  + ((V(A) - p(2))/(5*yrange)).^2);
%     [~,closest_spike] = min(dA);
%     B = [B; A(closest_spike)];
%     A(closest_spike) = [];

% elseif get(s.handles.mode_B2A,'Value') == 1
%     % find the closest B spike
%     dB = (((B-p(1))/(xrange)).^2  + ((V(B) - p(2))/(5*yrange)).^2);
%     [~,closest_spike] = min(dB);
%     A = [A; B(closest_spike)];
%     B(closest_spike) = [];

end

self.showSpikes;