function cdata = chunk(data,options)




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
	elseif strcmp(fn{j},'experiment_idx')
		cdata.(fn{j})=  repmat(data.experiment_idx,n_rows,1);
	else

		cdata.(fn{j}) = data.(fn{j})(1:options.ChunkSize/options.dt:end);
		
	end

end
