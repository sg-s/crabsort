% takes all files in current folder and puts them in appropriately
% named folders

function organize()

% get all files
allfiles = dir(pwd);
allfiles = allfiles(~[allfiles.isdir]);

for i = 1:length(allfiles)

	corelib.textbar(i,length(allfiles))

	if strcmp(allfiles(i).name(1),'.')
		continue
	end

	if length(allfiles(i).name) < 7
		continue
	end

	exp_name = allfiles(i).name(1:7);

	filelib.mkdir(exp_name)

	movefile(allfiles(i).name,fullfile(exp_name,allfiles(i).name))



end