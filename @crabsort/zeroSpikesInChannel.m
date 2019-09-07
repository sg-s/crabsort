% destroys spike information in an entire dataset
% for a given nerve_name

function zeroSpikesInChannel(nerve_name)

allfiles = dir('*.crabsort');

load('crabsort.common','-mat','common')

channel = find(strcmp(common.data_channel_names,nerve_name));

for i = 1:length(allfiles)
	clearvars -except allfiles i channel nerve_name
	load(allfiles(i).name,'-mat')
	crabsort_obj.spikes.dgn.DG = [];
	crabsort_obj.channel_stage(channel) = 3;
	save(allfiles(i).name,'crabsort_obj')
end