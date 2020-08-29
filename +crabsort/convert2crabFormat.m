% this function converts data in non .crab formats into 
% .crab format (an uncompressed HDF5 file)
% usage:
%
% crabsort.convert2crabFormat
% crabsort.convert2crabFormat()

function convert2crabFormat(options)


arguments
	options.DataDir char = pwd
	options.UseParallel (1,1) logical = false

end
	


allfolders = dir(options.DataDir);
allfolders(cellfun(@(x) strcmp(x(1),'.'),{allfolders.name})) = [];
allfolders(~[allfolders.isdir]) = [];

if length(allfolders) > 1

	for i = 1:length(allfolders)
		crabsort.convert2crabFormat('DataDir',fullfile(allfolders(i).folder,allfolders(i).name),'UseParallel',options.UseParallel);
	end
	return

end





allowed_file_extensions = {'*.abf','*.smr','*.mat'};




% first convert all files into .crab files

for i = 1:length(allowed_file_extensions)


	disp(allowed_file_extensions{i})

	allfiles = dir(fullfile(options.DataDir,allowed_file_extensions{i}));
	fprintf('File Name                     # Channels     Channel Name Hash\n')
	fprintf('---------------------------------------------------------\n')

	this_file_ext = allowed_file_extensions{i};


	if options.UseParallel

		parfor j = 1:length(allfiles)

			crabsort.convertFile2crabFormat(allfiles(j), this_file_ext);

		end

	else
		for j = 1:length(allfiles)

			crabsort.convertFile2crabFormat(allfiles(j), this_file_ext);

		end

	end


end




allfiles = dir(fullfile(options.DataDir,'*.crab'));
all_hashes = cell(length(allfiles),1);
all_channel_names = {};

for i = 1:length(allfiles)
	load(fullfile(allfiles(i).folder,allfiles(i).name),'-mat','builtin_channel_names');
	all_channel_names = unique([all_channel_names; builtin_channel_names(:)]);
	all_hashes{i} = hashlib.md5hash([builtin_channel_names{:}]);
end

% now go through all the .crab files and make them consistent 

if length(unique(all_hashes)) > 1
	disp('Inconsistent files, harmonizing...')


	for i = 1:length(allfiles)
		corelib.textbar(i,length(allfiles))


		load(fullfile(allfiles(i).folder,allfiles(i).name),'-mat')

		old_builtin_channel_names = builtin_channel_names;
		builtin_channel_names = all_channel_names;

		old_raw_data = raw_data;
		raw_data = zeros(size(old_raw_data,1),length(builtin_channel_names));

		for k = 1:length(old_builtin_channel_names)
			raw_data(:,strcmp(old_builtin_channel_names{k},all_channel_names)) = old_raw_data(:,k);
		end

		save(fullfile(allfiles(i).folder,allfiles(i).name),'raw_data','builtin_channel_names','-append')
	end

end
