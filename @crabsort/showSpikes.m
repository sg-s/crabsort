%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% shows all sorted spikes in all channels

function showSpikes(self, channels)


if nargin == 1
	channels = 1:self.n_channels;
end



% first, hide all spikes
for i = 1:length(channels)
	this_channel = channels(i);

	for j = 1:length(self.handles.ax.sorted_spikes(this_channel).unit)
		self.handles.ax.sorted_spikes(this_channel).unit(j).XData = NaN;
		self.handles.ax.sorted_spikes(this_channel).unit(j).YData = NaN;
	end
end

if isempty(self.spikes)
	return
end



for i = 1:length(channels)
	this_channel = channels(i);

	this_nerve = self.common.data_channel_names{this_channel};

	if ~isfield(self.spikes,this_nerve)
		continue
	end

	if isempty(self.spikes.(this_nerve))
		continue
	end

	if ~self.common.show_hide_channels(this_channel)
		continue
	end

	neuron_names = self.nerve2neuron.(this_nerve);


	if ~iscell(neuron_names)
		neuron_names = {neuron_names};
	end

	for j = 1:length(neuron_names)
		this_neuron = neuron_names{j};

		if ~isfield(self.spikes.(this_nerve),this_neuron)
			continue
		end

		spiketimes = self.spikes.(this_nerve).(this_neuron);
		self.handles.ax.sorted_spikes(this_channel).unit(j).XData = self.time(spiketimes);
		self.handles.ax.sorted_spikes(this_channel).unit(j).YData = self.raw_data(spiketimes,this_channel);
	end



end


drawnow;



