function destroyAllJobs(self,channel)

job_file_location = [self.path_name 'network'];

allfiles = dir([job_file_location filesep  mat2str(channel) '*.job']);

if isempty(allfiles)
	return
end


for i = 1:length(allfiles)
	delete([allfiles(i).folder filesep allfiles(i).name])
end

