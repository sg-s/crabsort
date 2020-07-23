function findExpsWithMissingMetadata


spikeloc = getpref('crabsort','store_spikes_here');
allexps = dir(spikeloc);


for i = 1:length(allexps)

	if strcmp(allexps(i).name(1),'.')
		continue
	end

	% get all .txt files
	allfiles = dir(fullfile(allexps(i).folder,allexps(i).name,'*.txt'));

	if length(allfiles) == 0
		disp(allexps(i).name)
	end

end