% deletes data (in .crab format) and associated .crabsort files 
% if certain conditions are met
% 
% exampple usage
% 
% to purge all data where the LP channel is blank (has a single value)
%
% use this: 
% crabsort.purgeData('LP',@(x) length(unique(x),1)

function purgeData(ChannelName, FcnHandle, Value)

allfiles = dir([pwd filesep '*.crab']);


delete_me = false(length(allfiles),1);

disp('Reading data...')
for i = 1:length(allfiles)

	corelib.textbar(i,length(allfiles))

	% load it 
	C = crabsort(false);
	C.file_name = allfiles(i).name;
	C.path_name = allfiles(i).folder;
	C.loadFile;


	channel = find(strcmp(C.common.data_channel_names,ChannelName));

	assert(length(channel) == 1,'Could not resolve channel')

	if FcnHandle(C.raw_data(:,channel)) == Value
		delete_me(i) = true;

	end

end

% now delete the files
% move the data files into a folder called "ignored"
filelib.mkdir('ignored');
for i = 1:length(allfiles)
	if ~delete_me(i)
		continue
	end

	movefile(allfiles(i).name,[allfiles(i).folder filesep 'ignored' filesep allfiles(i).name]);
end

% and delete all associated .crabsort files
[~,thisdir] = fileparts(pwd);

for i = 1:length(allfiles)

	if ~delete_me(i)
		continue
	end

	spike_file = [getpref('crabsort','store_spikes_here') filesep thisdir filesep allfiles(i).name '.crabsort'];

	if exist(spike_file,'file') == 2
		delete(spike_file)
	end

end
