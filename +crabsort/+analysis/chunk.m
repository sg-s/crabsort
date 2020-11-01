% chunks data into segements
% ignores data that is smaller than the chunk size
%
% usage
% data = crabsort.analysis.chunk(data,options)
%
% where options is a struct such as
%
% options.dt = 1e-3 % 1ms
% options.ChunkSize = 20 % seconds
% options.neurons = {'PD','LP'} % which neurons?

function cdata = chunk(data,options)

arguments
	data (:,1) struct
	options (1,1) struct
end

if length(data) > 1
	% need to handle multiple chunks


	% data hasn't been stacked. Still need to chunk
	cdata =  crabsort.analysis.chunk(data(1),options);
	fn = fieldnames(cdata);


	for i = 2:length(data)

		if max(data(i).time_offset) < options.ChunkSize
			continue
		end


		temp = crabsort.analysis.chunk(data(i),options);
		% glom them all together
		N2 = size(temp.experiment_idx,1);
		
		for j = 1:length(fn)
			if size(temp.(fn{j}),1) == N2
				cdata.(fn{j}) = [cdata.(fn{j}); temp.(fn{j})];
			else
				cdata.(fn{j}) = [cdata.(fn{j}) temp.(fn{j})];
			end

		end
	end

	return

end



n_rows = ceil(length(data.mask)*options.dt/options.ChunkSize);


cdata = struct;

% make matrices for every neuron 
for i = 1:length(options.neurons)
	cdata.(options.neurons{i}) = NaN(1e3,n_rows);
end



for i = 1:n_rows
	a = (i-1)*options.ChunkSize;
	z = a + options.ChunkSize;


	for j = 1:length(options.neurons)
		these_spikes = data.(options.neurons{j});
		these_spikes = these_spikes(these_spikes >= a & these_spikes <= z);
		if length(these_spikes) > 1e3
			these_spikes = these_spikes(1:1e3);
		end
		cdata.(options.neurons{j})(1:length(these_spikes),i) = these_spikes;

	end

end

fn = fieldnames(data);



for j = 1:length(fn)
	if any(strcmp(fn{j},options.neurons))
	elseif strcmp(fn{j},'T')
	elseif strcmp(fn{j},'time_offset')		
	elseif length(data.(fn{j}))== 1
		% scalar value, need to broadcast
		cdata.(fn{j}) =  repmat(data.(fn{j}),n_rows,1);

	else

		cdata.(fn{j}) = data.(fn{j})(1:options.ChunkSize/options.dt:end);
		
	end

end

cdata.time_offset = ((1:size(cdata.(options.neurons{1}),2))-1)*options.ChunkSize;
cdata.time_offset = cdata.time_offset(:);


% if there is some trailing data, should we censor it?
if floor(length(data.mask)*options.dt/options.ChunkSize) == n_rows
	% no need to censor because it works out exactly
else
	% censor the last data point because it's a fragment.
	cdata.mask(end) = 0;
end
