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
if self.channel_stage(channel) < 3
    return
end

ylimits = self.handles.ax.ax(channel).YLim;
xlimits = self.handles.ax.ax(channel).XLim;

xrange = (xlimits(2) - xlimits(1))/self.dt;
yrange = ylimits(2) - ylimits(1);

p(1) = p(1)/self.dt;

% get the width over which to search for spikes dynamically from the zoom factor
search_width = floor((.005*xrange));

V = self.raw_data(:,channel);
this_nerve = self.common.data_channel_names{channel};

if self.handles.mode_new_spike.Value == 1
    % snip out a small waveform around the point

    % need to update the spike sign control to match automate info, if it exists 
    try
        self.common.automate_info(self.channel_to_work_with).operation(1);
        operation = self.common.automate_info(self.channel_to_work_with).operation(1);
        for i = 1:length(operation.property)
            if strcmp(strjoin(operation.property{i},'.'),'handles.spike_sign_control.Value')
                self.handles.spike_sign_control.Value = operation.value{i};
            end
        end
    catch
        
    end

    if ~self.handles.spike_sign_control.Value
        [~,loc] = min(V(floor(p(1)-search_width:p(1)+search_width)));
    else
        [~,loc] = max(V(floor(p(1)-search_width:p(1)+search_width)));
    end

    new_spike = floor(loc + p(1) - search_width);

    % which neuron are we adding to
    S = self.handles.new_spike_type.String;
    if iscell(S)
        S = S{self.handles.new_spike_type.Value};
    end

    self.spikes.(this_nerve).(S) = sort([self.spikes.(this_nerve).(S); new_spike]);

elseif self.handles.mode_delete_spike.Value == 1

    % get all spikes on this nerve
    [spiketimes, st_by_unit] = self.getSpikesOnThisNerve;
    spiketimes = find(spiketimes);
    % find the closest spike
    D = (((spiketimes-p(1))/(xrange)).^2  + ((V(spiketimes) - p(2))/(5*yrange)).^2);

    [~,idx] = min(D);

    % go through every neuron on this channel and wipe this spike 
    fn = fieldnames(self.spikes.(this_nerve));
    for i = 1:length(fn)
        self.spikes.(this_nerve).(fn{i}) = setdiff(self.spikes.(this_nerve).(fn{i}),spiketimes(idx));
    end

end

self.showSpikes;