function mergeAll()


allfiles = dir([pwd filesep '*.crab']);
assert(length(allfiles)>0,'No data found. Make sure you have .crab files in this folder')

[~,thisdir]=fileparts(allfiles(1).folder);
savename = [thisdir '_merged.crab'];


if exist(savename) == 2
	disp('Already merged, aborting...')
	return
end


% first estimate the size of the matrix we need to make
data_size = 0;
n_channels = 0;
all_dt = NaN(length(allfiles),1);
disp('Estimating sizes...')
for i = 1:length(allfiles)

	corelib.textbar(i,length(allfiles))

	m = matfile([allfiles(i).folder filesep allfiles(i).name]);

	data_size = data_size + size(m.raw_data,1);
	n_channels = size(m.raw_data,2);

	all_dt(i) = m.dt;

end

assert(length(unique(all_dt)) == 1,'Files have different time resolutions, cannot proceed')

alldata = zeros(data_size,n_channels);

a = 1;


disp('Combining data...')
for i = 1:length(allfiles)

	corelib.textbar(i,length(allfiles))

	load([allfiles(i).folder filesep allfiles(i).name],'-mat');

	alldata(a:a+size(raw_data,1)-1,:) = raw_data;

	a = a + size(raw_data,1);

end

raw_data = alldata;

save(savename,'raw_data','builtin_channel_names','dt','metadata','-v7.3','-nocompression')


% delete all old files
for i = 1:length(allfiles)
	delete(allfiles(i).name)
end