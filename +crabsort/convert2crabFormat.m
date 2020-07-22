% this function converts all ABF files into the .crab 
% format, and then makes sure that the data is consistent 

function convert2crabFormat(DataDir)

if nargin == 0
	DataDir = pwd;
end

% does this folder contain folders? if so, then we need to drill deeper...
allfolders = dir(DataDir);

for i = 1:length(allfolders)
	if strcmp(allfolders(i).name(1),'.')
		continue
	end
	if allfolders(i).isdir
		crabsort.convert2crabFormat([allfolders(i).folder filesep allfolders(i).name]);
	end
end



allowed_file_extensions = {'*.abf','*.smr','*.mat'};




% first convert all files into .crab files

for i = 1:length(allowed_file_extensions)


	disp(allowed_file_extensions{i})

	allfiles = dir(fullfile(DataDir,allowed_file_extensions{i}));
	fprintf('File Name                     # Channels     Channel Name Hash\n')
	fprintf('---------------------------------------------------------\n')

	this_file_ext = allowed_file_extensions{i};

	parfor j = 1:length(allfiles)

		crabsort.convertFile2crabFormat(allfiles(j), this_file_ext);

	end

end



allfiles = dir('*.crab');
all_hashes = cell(length(allfiles),1);
all_channel_names = {};

for i = 1:length(allfiles)
	load(allfiles(i).name,'-mat','builtin_channel_names');

	all_channel_names = unique([all_channel_names; builtin_channel_names(:)]);

	all_hashes{i} = hashlib.md5hash([builtin_channel_names{:}]);
end

% now go through all the .crab files and make them consistent 

if length(unique(all_hashes)) > 1
	disp('Inconsistent files, harmonizing...')


	for j = 1:length(allfiles)
		corelib.textbar(j,length(allfiles))

		load(allfiles(j).name,'-mat')

		old_builtin_channel_names = builtin_channel_names;
		builtin_channel_names = all_channel_names;

		old_raw_data = raw_data;
		raw_data = zeros(size(old_raw_data,1),length(builtin_channel_names));

		for k = 1:length(old_builtin_channel_names)
			raw_data(:,strcmp(old_builtin_channel_names{k},all_channel_names)) = old_raw_data(:,k);
		end

		save(allfiles(j).name,'raw_data','builtin_channel_names','-append')
	end

end
