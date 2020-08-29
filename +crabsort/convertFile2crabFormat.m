

function convertFile2crabFormat(filename, file_ext)


% first check if it has already been converted
[~,a] = fileparts(filename.name);
if exist([filename.folder filesep a '.crab'],'file') == 2
	disp('Already converted, skipping...')
	return
end


self = crabsort(false);
self.path_name = filename.folder;
self.file_name = filename.name;

fprintf([strlib.fix(self.file_name,28) '  '])

% attempt to load the file directly
S.raw_data = [];

try

	[~,~,chosen_data_ext] = fileparts(self.file_name);
	chosen_data_ext = upper(chosen_data_ext(2:end));


	% load the file
	load_file_handle = str2func(['csLoadFile.' chosen_data_ext]);

	S = load_file_handle(self);

catch err
	disp('Failed to load file, error was')
	disp(err.message)
	
end


clearvars self


if isempty(S.raw_data)
	if ~exist(fullfile(filename.folder,'corrupted'),'dir')
		mkdir(fullfile(filename.folder,'corrupted'))
	end
	try
		movefile(fullfile(filename.folder,filename.name),fullfile(filename.folder,'corrupted' ,filename.name))
	catch
	end

	fprintf('FATAL: could not load file\n')
else

	fprintf([strlib.fix(mat2str(size(S.raw_data,2)),14) ' '])

	H = hashlib.md5hash([S.builtin_channel_names{:}]);
	fprintf([strlib.fix(H,15) '\n'])


	% do the conversion
	raw_data = S.raw_data;
	builtin_channel_names = S.builtin_channel_names;
	dt = S.time(2) - S.time(1);
	metadata = S.metadata;

	file_name = strrep(filename.name,file_ext(2:end),'.crab');
	save(fullfile(filename.folder,file_name),'raw_data','builtin_channel_names','builtin_channel_names','dt','metadata','-nocompression','-v7.3')

end