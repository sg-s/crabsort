function clean()

% checks every files, and makes sure we can load it. if we can't,
% puts it in a folder called "corrupted"

self = crabsort(false);

% figure out what file types we can work with
allowed_file_extensions = setdiff(unique({self.installed_plugins.data_extension}),'n/a');
allowed_file_extensions = cellfun(@(x) ['*.' x], allowed_file_extensions,'UniformOutput',false);
allowed_file_extensions = allowed_file_extensions(:);

self.path_name = pwd;

for i = 1:length(allowed_file_extensions)

	allfiles = dir(allowed_file_extensions{i});


	for j = 1:length(allfiles)
		self.file_name = allfiles(j).name;

		disp(['Checking: ' self.file_name])


		self.loadFile;

		if isempty(self.raw_data)
			if ~exist('corrupted','dir')
				mkdir('corrupted')
			end
			movefile(self.file_name,['corrupted' filesep self.file_name])
		end
		
	end

end