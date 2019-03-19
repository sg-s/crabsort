% computes metrics on a bunch of data generated
% by crabsort.consolidate

function data_out = computePeriods(data, varargin)







if length(data) > 1
	for i = 1:length(data)
		data_out(i) = crabsort.computePeriods(data(i), varargin{:});
	end
	return
end


neurons = {};
ibis = [];
idx = 1;
for i = 1:2:length(varargin)
	neurons{idx} = varargin{i};
	ibis(idx) = varargin{i+1};
	idx = idx + 1;

end


for i = 1:length(neurons)
	assert(isfield(data,neurons{i}),['Neuron not found in data: ' neurons{i}])


	data.([neurons{i} '_burst_starts']) = NaN;
	data.([neurons{i} '_burst_periods']) = NaN;
	data.([neurons{i} '_burst_durations']) = NaN;

	isis = diff(data.(neurons{i}));
	burst_starts =  circshift(isis > ibis(i),1);
	burst_ends = isis > ibis(i);

	this_burst_starts = data.(neurons{i})(burst_starts);
	this_burst_ends = data.(neurons{i})(burst_ends);
	burst_periods = diff(this_burst_starts);
	if isempty(this_burst_starts)
		continue
	end
	this_burst_starts(end) = [];


	data.([neurons{i} '_burst_starts']) = this_burst_starts;
	data.([neurons{i} '_burst_periods']) = burst_periods;


	if isempty(this_burst_starts) 
		continue
	end

	if this_burst_starts(1) > this_burst_ends(1)
		this_burst_ends(1) = [];
	end


	if length(this_burst_ends) == length(this_burst_starts)
		% all good
	elseif length(this_burst_ends) > length(this_burst_starts)
		this_burst_ends(end) = [];
	else
		keyboard
	end


	data.([neurons{i} '_burst_durations']) = this_burst_ends - this_burst_starts;
	

end

data_out = data;