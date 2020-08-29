function should_stop = loadNextUnsortedFile(self)

if self.verbosity > 9
	disp(mfilename)
end

self.saveData;

should_stop = false;

[~,~,ext] = fileparts(self.file_name);
allfiles = dir([self.path_name '*' ext]);
n_files = length(allfiles);

this_file_seq = self.getFileSequence;
allfiles = circshift(allfiles,-this_file_seq);


for i = 1:length(allfiles)

	[~,thisdir]=fileparts(allfiles(i).folder);

	crabsort_file = [getpref('crabsort','store_spikes_here') filesep thisdir filesep allfiles(i).name '.crabsort'];

	if exist(crabsort_file,'file') ~= 2
		% no .crabsort file, so must sort this
		self.file_name = allfiles(i).name;
		self.loadFile;
		return
	end

	% .crabsort file exists, load it and check if spikes are marked
	load(crabsort_file,'-mat')


	if crabsort_obj.channel_stage(self.channel_to_work_with) ~= 3
		self.file_name = allfiles(i).name;
		self.loadFile;
		return
	end

end

should_stop = true;

msgbox('All files have this channel sorted','All done!');