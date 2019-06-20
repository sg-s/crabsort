

function convertFile2crabFormat(filename, file_ext)


% first check if it has already been converted
[~,a] = fileparts(filename.name);
if exist([a '.crab'],'file') == 2
	return
end


self = crabsort(false);
self.path_name = pwd;
self.file_name = filename.name;

fprintf(strlib.fix(self.file_name,20))


self.loadFile;


if isempty(self.raw_data)
	if ~exist('corrupted','dir')
		mkdir('corrupted')
	end
	movefile(self.file_name,['corrupted' filesep self.file_name])

	fprintf('FATAL: could not load file\n')
else
	fprintf(strlib.fix(mat2str(size(self.raw_data,2)),15))
	H = hashlib.md5hash([self.builtin_channel_names{:}]);
	fprintf([strlib.fix(H,15) '\n'])


	% do the conversion
	raw_data = self.raw_data;
	builtin_channel_names = self.builtin_channel_names;
	dt = self.dt;
	metadata = self.metadata;

	file_name = strrep(self.file_name,file_ext(2:end),'.crab');
	save(file_name,'raw_data','builtin_channel_names','builtin_channel_names','dt','metadata','-nocompression','-v7.3')

end