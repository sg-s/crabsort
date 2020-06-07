function ignoreEntireFiles(self, src, ~)

if self.verbosity > 9
	disp(mfilename)
end

% get all files in this dataset
thisfile = self.file_name;
[~,~,ext]=fileparts(self.file_name);
allfiles = dir([self.path_name filesep '*' ext]);


if any(strfind(src.Text,'BEFORE'))

	for i = 1:length(allfiles)

		if strcmp(allfiles(i).name,thisfile)
			return
		end

		% load the file
		file_name = fullfile(getpref('crabsort','store_spikes_here'),pathlib.lowestFolder(self.path_name),[allfiles(i).name  '.crabsort']);

		if exist(file_name,'file') == 2

			load(file_name,'-mat','crabsort_obj')
			crabsort_obj.ignore_section.ons = 1;
			crabsort_obj.ignore_section.offs = crabsort_obj.raw_data_size(1);
			save(file_name,'crabsort_obj')
		end


	end

else
	
	for i = length(allfiles):-1:1

		if strcmp(allfiles(i).name,thisfile)
			return
		end

		% load the file
		file_name = fullfile(getpref('crabsort','store_spikes_here'),pathlib.lowestFolder(self.path_name),[allfiles(i).name  '.crabsort']);

		if exist(file_name,'file') == 2

			load(file_name,'-mat','crabsort_obj')
			crabsort_obj.ignore_section.ons = 1;
			crabsort_obj.ignore_section.offs = crabsort_obj.raw_data_size(1);
			save([allfiles(i).folder filesep allfiles(i).name '.crabsort'],'crabsort_obj')
		end


	end

end