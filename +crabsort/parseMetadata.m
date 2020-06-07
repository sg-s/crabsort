
% this function parses metadata and returns a structure
% metadata is assumed to be in this format:
%  
% 1234 32 % interpeted as temperature for this file
% 1234 proctolin 1e-3 % interpreted as this conc of proctolin for all subsequent files
% 1234 decentralized % interpreted as decentralized for all subsequent files

function metadata = parseMetadata(path_to_metadata, allfiles)

% read metadata.txt
lines = strsplit(fileread(path_to_metadata),'\n');


n_files = length(allfiles);

metadata.temperature = NaN(n_files,1);
metadata.decentralized = false(n_files,1);

% get the last four digits of every file name -- this will be the file identifier
file_identifiers = zeros(length(allfiles),1);
for i = 1:length(allfiles)
	z = min(strfind(allfiles(i).name,'.'));
	this_file_identifier = str2double(allfiles(i).name(z-4:z-1));
	if isnan(this_file_identifier)
		error(['Could not match numeric identifier to this file: ' allfiles(i).name])
	end
	file_identifiers(i) = this_file_identifier;
end


for i = 1:length(lines)
	
	this_line = strsplit(strtrim(lines{i}),' ');
	file_idx = find(str2double(this_line{1}) == file_identifiers);


	switch length(this_line)
	case 1
		% ignore it
	case 2
		if  strcmp(this_line{2},'decentralized')
			% get file_idx right
			if isempty(file_idx)
				file_idx = (find(file_identifiers > str2double(this_line{1}),1,'first'));
			end

			metadata.decentralized(file_idx:end) = true;


		elseif ~isempty(file_idx)
			% interpret as temperature that is stored in .txt file
			% e.g. in Sara's data 
			metadata.temperature(file_idx) = str2double(this_line{2});
		end
		

	case 3

		% interpret this as something + value
		% this could be modulator + concentration 

		% get file_idx right
		if isempty(file_idx)
			file_idx = (find(file_identifiers > str2double(this_line{1}),1,'first'));
		end


		thing_name = this_line{2};
		thing_value = str2double(this_line(3));
		if isnan(thing_value)
			thing_value = categorical(this_line(3));
		end
		if ~isfield(metadata,thing_name)
			if isnumeric(thing_value)
				metadata.(thing_name) = zeros(n_files,1);
			else
				metadata.(thing_name) = categorical(NaN(n_files,1));
			end
		end


		metadata.(thing_name)(file_idx:end) = thing_value;

	end


end