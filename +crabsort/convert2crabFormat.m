% this function converts all ABF files into the .crab 
% format, and then makes sure that the data is consistent 

function convert2crabFormat()



self = crabsort(false);

allowed_file_extensions = {'*.abf'};

self.path_name = pwd;

for i = 1:length(allowed_file_extensions)

	allfiles = dir(allowed_file_extensions{i});
	fprintf('File Name           # Channels     Channel Name Hash\n')
	fprintf('-----------------------------------------------\n')


	n_channels = NaN(length(allfiles),1);
	channel_name_hash = {};
	all_channel_names = {};

	for j = 1:length(allfiles)
		self.file_name = allfiles(j).name;

		fprintf(flstring(self.file_name,20))


		self.loadFile;
	

		if isempty(self.raw_data)
			if ~exist('corrupted','dir')
				mkdir('corrupted')
			end
			movefile(self.file_name,['corrupted' filesep self.file_name])

			fprintf('FATAL: could not load file\n')
		else
			fprintf(flstring(mat2str(size(self.raw_data,2)),15))
			H = GetMD5([self.builtin_channel_names{:}]);
			fprintf([flstring(H,15) '\n'])

			all_channel_names = unique([all_channel_names; self.builtin_channel_names]);


			n_channels(j) = size(self.raw_data,2);
			channel_name_hash{j} = H;

			% do the conversion
			raw_data = self.raw_data;
			builtin_channel_names = self.builtin_channel_names;
			dt = self.dt;
			metadata = self.metadata;

			file_name = strrep(self.file_name,allowed_file_extensions{i}(2:end),'.crab');
			save(file_name,'raw_data','builtin_channel_names','builtin_channel_names','dt','metadata','-nocompression','-v7.3')

		end
		
	end

	% now go through all the .crab files and make them consistent 
	if length(unique(channel_name_hash)) > 1
		disp('Inconsistent files, harmonizing...')


		allfiles = dir('*.crab');
		for j = 1:length(allfiles)
			textbar(j,length(allfiles))

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

end

