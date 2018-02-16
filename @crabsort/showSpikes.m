%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% shows all sorted spikes in all channels

function showSpikes(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% first, hide all spikes
for i = 1:length(self.handles.ax.sorted_spikes)
	for j = 1:length(self.handles.ax.sorted_spikes(i).unit)
		self.handles.ax.sorted_spikes(i).unit(j).XData = NaN;
		self.handles.ax.sorted_spikes(i).unit(j).YData = NaN;
	end
end

if isempty(self.spikes)
	return
end


fn = fieldnames(self.spikes);

for i = 1:length(fn)

	this_nerve = fn{i};

	idx = find(strcmp(self.common.data_channel_names,fn{i}));

	if ~self.common.show_hide_channels(idx)
		continue
	end


	fn2 = fieldnames(self.spikes.(fn{i}));
	for j = 1:length(fn2)
		this_neuron = fn2{j};

		spiketimes = self.spikes.(fn{i}).(fn2{j});
		self.handles.ax.sorted_spikes(idx).unit(j).XData = self.time(spiketimes);
		self.handles.ax.sorted_spikes(idx).unit(j).YData = self.raw_data(spiketimes,idx);

	end

end