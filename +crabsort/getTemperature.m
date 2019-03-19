function temperature = getTemperature(obj, options)

channel =  find(strcmp(obj.common.data_channel_names,'temperature'));

if isempty(channel)
	error('temperature channel not found')
end

temperature = obj.raw_data(:,channel);

S = round(options.dt/obj.dt);
temperature = temperature(1:S:end);