function leftClickCallback(self,p)

if self.verbosity > 9
	disp(mfilename)
end

if isempty(self.channel_to_work_with)
	return
end


channel = self.channel_to_work_with;

if self.channel_stage(channel) == 0
	return
end

xlimits = self.handles.ax.ax(channel).XLim;
xrange = (xlimits(2) - xlimits(1))/self.dt;
p(1) = p(1)/self.dt;

% get the width over which to search for spikes dynamically from the zoom factor
search_width = floor((.005*xrange));

V = self.raw_data(:,channel);
this_nerve = self.common.data_channel_names{channel};


% find closest identified point 
[spiketimes, labels] = self.getLabelledSpikes;


if strcmp(upper(this_nerve),this_nerve)
	% intracellular
	new_spike_name = this_nerve;
	self.handles.new_spike_type.String = this_nerve;
else

	if iscell(self.handles.new_spike_type.String)
		new_spike_name = self.handles.new_spike_type.String{self.handles.new_spike_type.Value};
	else
		new_spike_name = self.handles.new_spike_type.String;
	end
end



uncertain_spikes = round(self.handles.ax.uncertain_spikes(channel).XData/self.dt);



if self.handles.mode_off.Value == 1
	% the only thing possible is to affirm uncertain spikes
	% so we're going to find the closest uncertain spike

	if isnan(uncertain_spikes)
		disp('no uncertain_spikes')
		return
	end

	if isempty(uncertain_spikes)
		disp('no uncertain_spikes')
		return
	end

	closest_uncertain_spike = uncertain_spikes(corelib.closest(uncertain_spikes,p(1)));

	if abs(closest_uncertain_spike - p(1)) > search_width
		% disp('out of bounds')
		return
	end



	old_spike_name = char(labels(spiketimes==closest_uncertain_spike));

	if isempty(old_spike_name)
		old_spike_name = 'Noise';
	end


	% affirm
	self.affirmSpike(channel, closest_uncertain_spike, old_spike_name);






else
	% we are not in OFF mode. so we're adding something 

	if ~self.handles.spike_sign_control.Value
	    [~,loc] = min(V(floor(p(1)-search_width:p(1)+search_width)));
	else
	    [~,loc] = max(V(floor(p(1)-search_width:p(1)+search_width)));
	end

	new_spike = floor(loc + p(1) - search_width) - 1;



	old_spike_name = char(labels(spiketimes==new_spike));

	if isempty(old_spike_name)
		old_spike_name = 'Noise';
	end


	if strcmp(old_spike_name,new_spike_name)
		% affirmation
		% do nothing
	else
		% relabelling

		self.say(['relabelling spike: ' old_spike_name '->' new_spike_name])		

		% remove from the old name
		if ~strcmp(old_spike_name,'Noise')
			self.spikes.(this_nerve).(old_spike_name) = setdiff(self.spikes.(this_nerve).(old_spike_name), new_spike);
		end


		% add it to the new name
		self.spikes.(this_nerve).(new_spike_name) = [self.spikes.(this_nerve).(new_spike_name); new_spike];

		% add this to NNdata

		if ~isempty(self.common.NNdata(channel).spiketimes)
			self.loadSDPFromNNdata;
			self.putative_spikes(:,channel) = 0;
			self.putative_spikes(new_spike,channel) = 1;
			self.getDataToReduce;

			self.common.NNdata(channel) = self.common.NNdata(channel).addDataFrame(self.data_to_reduce,self.getFileSequence,new_spike,categorical({new_spike_name}));
		end

		

		set(self.handles.ax.found_spikes(channel),'XData',NaN,'YData',NaN);


		self.showSpikes(channel);


	end


	% if this spike uncertain? 
	if any(uncertain_spikes == new_spike)
		% new spike is uncertain, need to mark as certain
		self.affirmSpike(channel, new_spike, new_spike_name);
	end




end



