function raw_data = getRawData(obj, options)


for i = length(options.nerves):-1:1

	channel =  find(strcmp(obj.common.data_channel_names,options.nerves{i}));

	if isempty(channel)
		error('raw data channel not found')
	end

	this_raw_data = obj.raw_data(:,channel);

	S = round(options.dt/obj.dt);
	raw_data(:,i) = this_raw_data(1:S:end);


end
