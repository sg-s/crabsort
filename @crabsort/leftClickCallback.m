function leftClickCallback(self,p)

if isempty(self.channel_to_work_with)
	return
end

channel = self.channel_to_work_with;


xlimits = self.handles.ax.ax(channel).XLim;

xrange = (xlimits(2) - xlimits(1))/self.dt;

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



this_nerve_name = self.common.data_channel_names{self.channel_to_work_with};


% find closest identified point 
[spiketimes, labels] = self.getLabelledSpikes;

new_spike_name = self.handles.new_spike_type.String{self.handles.new_spike_type.Value};

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
if ~isfield(self.spikes.(this_nerve),new_spike_name)
	self.spikes.(this_nerve).(new_spike_name) = [];
end

old_spike_name = char(labels(spiketimes==new_spike));


if any(spiketimes==new_spike) && self.handles.mode_off.Value ~=1
	% clicked point is an identified spike that may or may not be uncertain
	

	

	if strcmp(old_spike_name,new_spike_name)
		% we're trying to mark this spike for what it already is
		beep
		return
	else
		self.say(['relabelling spike: ' old_spike_name '->' new_spike_name])		

		% remove from the old name
		self.spikes.(this_nerve).(old_spike_name) = setdiff(self.spikes.(this_nerve).(old_spike_name), new_spike);


		% add it to the new name
		self.spikes.(this_nerve).(new_spike_name) = [self.spikes.(this_nerve).(new_spike_name); new_spike];

		% add this to NNdata
		self.common.NNdata(channel) = self.common.NNdata(channel).addDataFrame(self.data_to_reduce,self.getFileSequence,new_spike,categorical({new_spike_name}));
	end


elseif self.handles.mode_off.Value ~= 1
	% clicked point is a unidentified spike
	self.say('Adding new spike');

	self.common.NNdata(channel) = self.common.NNdata(channel).addDataFrame(self.data_to_reduce,self.getFileSequence,new_spike,categorical({new_spike_name}));

	% add
	self.spikes.(this_nerve).(new_spike_name) = sort([self.spikes.(this_nerve).(new_spike_name); new_spike]);
elseif self.handles.mode_off.Value == 1
	% we are affirming this uncertain spike

	if any(uncertain_spikes == new_spike)
		self.say('Adding this spike to the training data')

		self.common.NNdata(channel) = self.common.NNdata(channel).addDataFrame(self.data_to_reduce,self.getFileSequence,new_spike,categorical({old_spike_name}));


		% remove from uncertain spikes
		self.handles.ax.uncertain_spikes(channel).XData(uncertain_spikes == new_spike) = [];
		self.handles.ax.uncertain_spikes(channel).YData(uncertain_spikes == new_spike) = [];


	end

end



self.putative_spikes(:,channel) = 0;
self.showSpikes;