function cdata = chunk(data,options)

% TODO: chunk data too

time = (1:length(data.mask))*options.dt;
n_chunks = ceil(max(time)/options.ChunkSize);
cdata = repmat(data,n_chunks,1);


for i = 1:n_chunks


	a = (i-1)*options.ChunkSize;
	z = (i)*options.ChunkSize;

	cdata(i).mask = cdata(i).mask(time >= a & time < z);

	for j = 1:length(options.neurons)
		spiketimes = cdata(i).(options.neurons{j});
		spiketimes(spiketimes < a | spiketimes > z) = [];
		cdata(i).(options.neurons{j}) = spiketimes;

	end

	cdata(i).time_offset = a;
	cdata(i).T = options.ChunkSize;



end
