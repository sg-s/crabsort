function data = measureSNR(file_name, data)

load([file_name.folder filesep file_name.name],'-mat','crabsort_obj')

disp(file_name.name)

self = crabsort(false);

self.path_name = file_name.folder;
self.file_name = strrep(file_name.name,'.crabsort','');

self.loadFile;

% window size to average over the "noise"
N = round(.1/self.dt);

nerve_names = self.common.data_channel_names;

if isempty(self.spikes)
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


		mean_spike_ht = abs(mean(self.raw_data(spike_locations,i)));

		try
			temp = reshape(self.raw_data(:,i),N,round(self.raw_data_size(1)/N));
		catch
			continue
		end

		rm_this = unique(round(spike_locations*self.dt*10));
		rm_this(rm_this == 0) = [];
		temp(:,rm_this) = [];
		temp(1:round(N/2),:) = [];
		noise_sigma =  mean(std(temp));

		% save all of this
		data.file_name = [data.file_name; self.file_name];
		data.nerve_name = [data.nerve_name; nerve];
		data.neuron_name = [data.neuron_name; neuron_names{j}];
		data.SNR = [data.SNR; (mean_spike_ht/noise_sigma)^2];

	end



end