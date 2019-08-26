function should_stop = loadNextUnsortedFile(self)

if self.verbosity > 9
	disp(mfilename)
end

should_stop = false;

[~,~,ext] = fileparts(self.file_name);
allfiles = dir([self.path_name '*' ext]);
n_files = length(allfiles);

this_file_seq = self.getFileSequence;
allfiles = circshift(allfiles,-this_file_seq);



for i = 1:length(allfiles)

	if exist([self.path_name filesep allfiles(i).name '.crabsort'],'file') ~= 2
		% no .crabsort file, so must sort this
		self.file_name = allfiles(i).name;
		self.loadFile;
		return
	end

	% .crabsort file exists, load it and check if spikes are marked
	load([self.path_name filesep allfiles(i).name '.crabsort'],'-mat')


	if crabsort_obj.channel_stage(self.channel_to_work_with) ~= 3
		self.file_name = allfiles(i).name;
		self.loadFile;
		return
	end

end

should_stop = true;