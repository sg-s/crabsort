function data = measureSNR(file_name, data)

load([file_name.folder filesep file_name.name],'-mat','crabsort_obj')

disp(file_name.name)

self = crabsort(false);

self.path_name = file_name.folder;
self.file_name = strrep(file_name.name,'.crabsort','');

self.loadFile;

if isempty(self.raw_data)
	disp('no data')
	return
end

% window size to average over the "noise"
N = round(.1/self.dt);

nerve_names = self.common.data_channel_names;

if isempty(self.spikes)
	disp('no spikes')
	return
end

fn = fieldnames(self.spikes);

for i = 1:(self.raw_data_size(2))
	if isempty(nerve_names{i})
		continue
	end

	nerve = nerve_names{i};

	if ~any(strcmp(fn,nerve))
		continue
	end

	neuron_names = fieldnames(self.spikes.(nerve));

	for j = 1:length(neuron_names)

		spike_locations = self.spikes.(nerve).(neuron_names{j});

		if isempty(spike_locations)
			continue
		end


		% find minimum absolute spike height
		min_spike_ht = abs(min(self.raw_data(spike_locations,i)));


		% chunbk data
		temp = veclib.chunk(self.raw_data(:,i),N);


		try
			rm_this = unique(floor(spike_locations*self.dt*10));
			rm_this(rm_this == 0) = [];
			temp(:,rm_this) = [];

			noise_sigma =  mean(std(temp));

			% save all of this
			data.file_name = [data.file_name; self.file_name];
			data.path_name = [data.path_name; self.path_name];
			data.nerve_name = [data.nerve_name; nerve];
			data.neuron_name = [data.neuron_name; neuron_names{j}];
			data.SNR = [data.SNR; (min_spike_ht/noise_sigma)^2];
		catch
		end


	end



end
