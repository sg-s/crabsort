function splitABFFile(varargin)

options.abf_file_name = '';
options.max_file_length = 120; % seconds
options.deltat = 1e-4; % s

options = corelib.parseNameValueArguments(options,varargin{:});


[~,~,file_ext] = fileparts(options.abf_file_name);


[raw_data,dt,metadata]=filelib.abfload(options.abf_file_name);

dt = dt/1e6; % now in seconds

time = (1:size(raw_data,1))*dt; % in seconds

sub_sample = round(options.deltat/dt);

raw_data = raw_data(1:sub_sample:end,:);
time = time(1:sub_sample:end);
dt = options.deltat;

all_raw_data = raw_data;

builtin_channel_names = metadata.recChNames;




if max(time) <= options.max_file_length
	disp('not splitting up file...')
	file_name = strrep(options.abf_file_name,file_ext(2:end),'crab');
	save(file_name,'raw_data','builtin_channel_names','dt','metadata','-nocompression','-v7.3')
	return
end

file_breaks = round((0:options.max_file_length:max(time))/dt);
file_breaks(file_breaks==0) = 1;

for i = 1:length(file_breaks)-1
	raw_data = all_raw_data(file_breaks(i):file_breaks(i+1),:);
	file_name = strrep(options.abf_file_name,file_ext(2:end),'crab');

	idx = mat2str(i);
	if length(idx) < 3
		idx = [repmat('0',1,3-length(idx)) idx];
	end

	file_name = strrep(file_name,'.crab',['_' idx '.crab']);
	save(file_name,'raw_data','builtin_channel_names','dt','metadata','-nocompression','-v7.3')

end

if file_breaks(end)*dt < max(time)
	raw_data = all_raw_data(file_breaks(end):end,:);
	file_name = strrep(options.abf_file_name,file_ext(2:end),'crab');

	idx = mat2str(i+1);
	if length(idx) < 3
		idx = [repmat('0',1,3-length(idx)) idx];
	end

	file_name = strrep(file_name,'.crab',['_' idx '.crab']);
	save(file_name,'raw_data','builtin_channel_names','dt','metadata','-nocompression','-v7.3')
end