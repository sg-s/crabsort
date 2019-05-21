% destroys all job files
function destroyAllJobs(self)

job_file_location = [self.path_name 'network'];

allfiles = dir([job_file_location filesep  '*.job']);

if isempty(allfiles)
	return
end


for i = 1:length(allfiles)
	delete([allfiles(i).folder filesep allfiles(i).name])
end

