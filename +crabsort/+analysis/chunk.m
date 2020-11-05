% chunks data into segements
% ignores data that is smaller than the chunk size
%
% usage
% data = crabsort.analysis.chunk(data)
% data = crabsort.analysis.chunk(data, neurons)
% data = crabsort.analysis.chunk(data, neurons, ChunkSize)
% data = crabsort.analysis.chunk(data, neurons, ChunkSize, dt)
% 

function cdata = chunk(data, neurons, ChunkSize, dt)

arguments
	data (:,1) struct
	neurons (:,1) cell =  {'PD'; 'LP'}
	ChunkSize (1,1) double = 20 % seconds
	dt (1,1) double = 1e-3  % seconds
end

if length(data) > 1
	% each element of data is a different file
	% we will chunk within each file, since
	% we have no guarantees about continuity across files
	% I learnt the hard way that so called "gapless" ABF
	% files do indeed have gaps

	% chunk the first file
	cdata =  crabsort.analysis.chunk(data(1),neurons, ChunkSize, dt);
	fn = fieldnames(cdata);

	% chunk all the rest and glom them together
	for i = 2:length(data)

		temp = crabsort.analysis.chunk(data(i),neurons, ChunkSize, dt);
		
		% glom them all together
		for j = 1:length(fn)
			cdata.(fn{j}) = [cdata.(fn{j}); temp.(fn{j})];
		end
	end

	return

end





assert(length(data)==1,'Expected a scalar structure')

n_rows = ceil(length(data.mask)*dt/ChunkSize);

cdata = struct;

% make matrices for every neuron 
for i = 1:length(neurons)
	cdata.(neurons{i}) = NaN(n_rows,1e3);
end


% split spikes into chunks
for i = 1:n_rows
	a = (i-1)*ChunkSize;
	z = a + ChunkSize;


	for j = 1:length(neurons)
		these_spikes = data.(neurons{j});
		these_spikes = these_spikes(these_spikes >= a & these_spikes <= z);
		if length(these_spikes) > 1e3
			these_spikes = these_spikes(1:1e3);
		end
		cdata.(neurons{j})(i,1:length(these_spikes)) = these_spikes;

	end

end


% now chunk all metadata and anything else there is in data
fn = fieldnames(data);


for j = 1:length(fn)
	if any(strcmp(fn{j},neurons))
	elseif strcmp(fn{j},'T')
	elseif strcmp(fn{j},'mask')

		% we need to be conservative about throwing out chunks 
		% that are masked, so even if one point in the chunk is masked,
		% then the whole chunk should be masked
		N = floor(length(data.mask)/n_rows);
		cdata.mask = veclib.subSample(data.(fn{j}),N,@min);

	elseif strcmp(fn{j},'temperature')	
		% temperature is at a different timescale,
		% let's try to figure it out
		temperature_time = linspace(0,data.T,length(data.temperature));
		sample_times = ((1:n_rows)-1)*ChunkSize;
		if length(temperature_time) > 1
			
			cdata.temperature = interp1(temperature_time,data.temperature,sample_times,'linear','extrap');

			cdata.temperature = cdata.temperature(:);
		else
			cdata.temperature = repmat(data.temperature(1),n_rows,1);
		end
	elseif length(data.(fn{j}))== 1
		% scalar value, need to broadcast
		cdata.(fn{j}) =  repmat(data.(fn{j}),n_rows,1);

	else

		cdata.(fn{j}) = data.(fn{j})(1:ChunkSize/dt:end);
		
	end

end


if n_rows == 0
	cdata.mask = cdata.mask(:);
end

cdata.time_offset = ((1:size(cdata.(neurons{1}),1))-1)*ChunkSize;
cdata.time_offset = cdata.time_offset(:);



% if there is some trailing data, should we censor it?
if floor(length(data.mask)*dt/ChunkSize) == n_rows
	% no need to censor because it works out exactly
else
	% censor the last data point because it's a fragment.
	cdata.mask(end) = 0;
end




% checks that they are all the same size
fn = fieldnames(cdata);
for i = 2:length(fn)
	if size(cdata.(fn{i}),1) ~= size(cdata.(fn{1}),1)
		keyboard
	end
end


