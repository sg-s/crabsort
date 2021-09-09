% this helper function checks every metadata
% .txt file and makes sure that file 
% identifiers are monotonically increasing
% non-monotonic fileids may suggest mistakes
% in metadata


function checkMetadata()

spikesfolder = getpref('crabsort','store_spikes_here');


allexps = dir(spikesfolder);
bad_exps = false(length(allexps),1);
for i = 1:length(allexps)
	if strcmp(allexps(i).name(1),'.')
		continue
	end
	if ~allexps(i).isdir
		continue
	end

	metadatafile = dir(fullfile(allexps(i).folder,allexps(i).name,'*.txt'));

	lines = fileread(fullfile(metadatafile.folder,metadatafile.name));
	lines = strsplit(lines,'\n');

	fileids = NaN(length(lines),1);
	for j = 1:length(lines)
		thisline = strsplit(lines{j});
		fileids(j) = str2double(thisline{1});
	end

	fileids(isnan(fileids)) = [];

	if all(sort(fileids) == fileids)
		continue
	end

	bad_exps(i) = true;
end


disp({allexps(bad_exps).name}')