function leftClickCallback(self,p)

if isempty(self.channel_to_work_with)
	return
end

if self.handles.mode_off.Value
	return
end



channel = self.channel_to_work_with;




ylimits = self.handles.ax.ax(channel).YLim;
xlimits = self.handles.ax.ax(channel).XLim;

xrange = (xlimits(2) - xlimits(1))/self.dt;
yrange = ylimits(2) - ylimits(1);

p(1) = p(1)/self.dt;

% get the width over which to search for spikes dynamically from the zoom factor
search_width = floor((.005*xrange));

V = self.raw_data(:,channel);
this_nerve = self.common.data_channel_names{channel};



% snip out a small waveform around the point

% need to update the spike sign control to match automate info, if it exists
self.NNsync(); 

if ~self.handles.spike_sign_control.Value
    [~,loc] = min(V(floor(p(1)-search_width:p(1)+search_width)));
else
    [~,loc] = max(V(floor(p(1)-search_width:p(1)+search_width)));
end

new_spike = floor(loc + p(1) - search_width) - 1;

% which neuron are we adding to
S = self.handles.new_spike_type.String;
if iscell(S)
    S = S{self.handles.new_spike_type.Value};
end

label_idx = self.handles.new_spike_type.Value;

% find closest identified point 
[spiketimes, st_by_unit] = self.getSpikesOnThisNerve;
spiketimes = find(spiketimes);

uncertain_spikes = round(self.handles.ax.uncertain_spikes(channel).XData/self.dt);

if isempty(uncertain_spikes)
	uncertain_spikes = 0;
end

if isempty(spiketimes)
	spiketimes = 0;
end


% now lock the channel names on this channel and prevent the user from ever renaming it
self.common.channel_name_lock(self.channel_to_work_with) = true;
self.handles.ax.channel_label_chooser(self.channel_to_work_with).Enable = 'off';

self.NNsync(); 
self.putative_spikes(:,channel) = 0;
self.putative_spikes(new_spike,channel) = 1;
self.getDataToReduce;


% check that the spikes structure is OK
if ~isfield(self.spikes,this_nerve)
	self.spikes.(this_nerve) = [];
end
if ~isfield(self.spikes.(this_nerve),S)
	self.spikes.(this_nerve).(S) = [];
end

if any(spiketimes==new_spike) & any(uncertain_spikes == new_spike)
	% clicked point is an identified spike that is uncertain
	self.handles.main_fig.Name = [self.file_name ' -- Adding this spike to training data'];
	self.common.NNdata(channel) = self.common.NNdata(channel).addDataFrame(self.data_to_reduce,self.getFileSequence,new_spike,label_idx);
elseif any(spiketimes==new_spike) & ~any(uncertain_spikes == new_spike)
	% clicked point is an identified, certain spike
	self.handles.main_fig.Name = [self.file_name ' -- This spike has already been identified'];
	beep
	return
elseif ~any(spiketimes==new_spike) & any(uncertain_spikes == new_spike)
	% clicked point is an unidentified spike, but it's uncertain
	self.handles.main_fig.Name = [self.file_name ' -- Adding new spike'];
	self.common.NNdata(channel) = self.common.NNdata(channel).addDataFrame(self.data_to_reduce,self.getFileSequence,new_spike,label_idx);

	% add
	self.spikes.(this_nerve).(S) = sort([self.spikes.(this_nerve).(S); new_spike]);

else 
	% clicked point is a unidentified spike
	self.handles.main_fig.Name = [self.file_name ' -- Adding new spike'];
	self.common.NNdata(channel) = self.common.NNdata(channel).addDataFrame(self.data_to_reduce,self.getFileSequence,new_spike,label_idx);

	% add
	self.spikes.(this_nerve).(S) = sort([self.spikes.(this_nerve).(S); new_spike]);

end



self.putative_spikes(:,channel) = 0;
self.showSpikes;