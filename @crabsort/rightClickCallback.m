function rightClickCallback(self,p)

if isempty(self.channel_to_work_with)
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




% find closest identified point 
[spiketimes, st_by_unit] = self.getSpikesOnThisNerve;
spiketimes = find(spiketimes);

uncertain_spikes = round(self.handles.ax.uncertain_spikes(channel).XData/self.dt);
uncertain_spikes_y = self.handles.ax.uncertain_spikes(channel).YData;

dist_to_identified_spikes = (((spiketimes-p(1))/(xrange)).^2  + ((V(spiketimes) - p(2))/(5*yrange)).^2);

dist_to_uncertain_spikes = (((uncertain_spikes-p(1))/(xrange)).^2  + ((uncertain_spikes_y - p(2))/(5*yrange)).^2);





if min(dist_to_uncertain_spikes) < min(dist_to_identified_spikes)
	self.handles.main_fig.Name = [self.file_name ' -- Marking uncertain spike as noise'];


	this_spike = uncertain_spikes(dist_to_uncertain_spikes == min(dist_to_uncertain_spikes));


elseif min(dist_to_uncertain_spikes) == min(dist_to_identified_spikes)
	disp('user is clicking on an uncertain spike that is marked as a spike')
	keyboard
elseif min(dist_to_uncertain_spikes) > min(dist_to_identified_spikes)
	self.handles.main_fig.Name = [self.file_name ' -- Deleting identified spike'];
	this_spike = spiketimes(dist_to_identified_spikes == min(dist_to_identified_spikes));

	% mark this spike as noise
	self.markAsNoise(this_nerve,this_spike);


elseif isempty(dist_to_uncertain_spikes)
	self.handles.main_fig.Name = [self.file_name ' -- Deleting identified spike'];
	this_spike = spiketimes(dist_to_identified_spikes == min(dist_to_identified_spikes));

	% mark this spike as noise
	self.markAsNoise(this_nerve,this_spike);

elseif isnan(min(dist_to_uncertain_spikes)) 
	self.handles.main_fig.Name = [self.file_name ' -- Deleting identified spike'];
	this_spike = spiketimes(dist_to_identified_spikes == min(dist_to_identified_spikes));

	% mark this spike as noise
	self.markAsNoise(this_nerve,this_spike);
else

	disp('what')
	keyboard
end

self.NNsync(); 
self.putative_spikes(:,channel) = 0;
self.putative_spikes(this_spike,channel) = 1;
self.getDataToReduce;

self.common.NNdata(channel) = self.common.NNdata(channel).addDataFrame(self.data_to_reduce,self.getFileSequence,this_spike,0);

self.putative_spikes(:,channel) = 0;
self.showSpikes;