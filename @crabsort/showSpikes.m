%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% shows all sorted spikes in all channels

function showSpikes(self)


if isempty(self.spikes)
	return
end

fn = fieldnames(self.spikes);


for i = 1:length(fn)
	this_nerve = fn{i};

	idx = find(strcmp(self.data_channel_names,fn{i}));


	fn2 = fieldnames(self.spikes.(fn{i}));
	for j = 1:length(fn2)
		this_neuron = fn2{j};
		% try
			spiketimes = self.spikes.(fn{i}).(fn2{j});
			self.handles.sorted_spikes(idx).unit(j).XData = self.time(spiketimes);
			self.handles.sorted_spikes(idx).unit(j).YData = self.raw_data(spiketimes,idx);
		% catch
		% 	% probably the plot doesn't exist. make it
		% 	keyboard
		% end
	end

end