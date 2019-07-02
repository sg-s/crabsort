% computes metrics on a bunch of data generated
% by crabsort.consolidate

function data_out = computePeriods(data, varargin)




if length(data) > 1
	for i = 1:length(data)
		data_out(i) = crabsort.computePeriods(data(i), varargin{:});
	end
	return
end


options.neurons = {};
options.ibis = [];
options.min_spikes_per_burst = 1;


options = corelib.parseNameValueArguments(options, varargin{:});

neurons = options.neurons;
ibis = options.ibis;
min_spikes_per_burst = options.min_spikes_per_burst;

for i = 1:length(neurons)
	assert(isfield(data,neurons{i}),['Neuron not found in data: ' neurons{i}])


	data.([neurons{i} '_burst_starts']) = NaN;
	data.([neurons{i} '_burst_periods']) = NaN;
	data.([neurons{i} '_burst_durations']) = NaN;
	data.([neurons{i} '_burst_ends']) = NaN;
	data.([neurons{i} '_n_spikes_per_burst']) = NaN;


	spiketimes = data.(neurons{i});

	isis = diff(spiketimes);
	burst_starts =  find(circshift(isis > ibis(i),1));
	burst_ends = find(isis > ibis(i));

	if isempty(burst_starts)
		continue
	end

	if isempty(burst_ends)
		continue
	end

	% can't have a burst end before a burst start
	burst_ends(burst_ends<burst_starts(1)) = [];

	if isempty(burst_ends)
		continue
	end

	% can't have a burst start after the last burst end
	burst_starts(burst_starts>burst_ends(end)) = [];

	if length(burst_starts) ~= length(burst_ends)
		if self.debug_mode
			keyboard
		else
			warning('Error computing periods.')
		end
	end

	n_spikes_per_burst = burst_ends - burst_starts;


	burst_starts(n_spikes_per_burst<min_spikes_per_burst) = [];
	burst_ends(n_spikes_per_burst<min_spikes_per_burst) = [];
	n_spikes_per_burst(n_spikes_per_burst<min_spikes_per_burst) = [];
	

	if isempty(burst_starts)
		continue
	end

	if isempty(burst_ends)
		continue
	end


	% convert to real time 
	burst_starts = spiketimes(burst_starts);
	burst_ends = spiketimes(burst_ends);
	burst_periods = [diff(burst_starts); NaN];


	burst_durations = burst_ends - burst_starts;

	data.([neurons{i} '_n_spikes_per_burst']) = n_spikes_per_burst;
	data.([neurons{i} '_burst_starts']) = burst_starts;
	data.([neurons{i} '_burst_periods']) = burst_periods;
	data.([neurons{i} '_burst_ends']) = burst_ends;
	data.([neurons{i} '_burst_durations']) = burst_durations;
	

end

data_out = data;