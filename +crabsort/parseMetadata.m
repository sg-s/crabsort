function metadata = parseMetadata(path_to_metadata, allfiles)

% read metadata.txt
lines = strsplit(fileread(path_to_metadata),'\n');

n_files = length(allfiles);

metadata.temperature = NaN(n_files,1);
metadata.decentralized = false(n_files,1);

for i = 1:length(lines)
	this_line =strsplit(lines{i},' ');
	file_idx = find(~cellfun(@isempty,cellfun(@(x) strfind(x,this_line{1}), {allfiles.name},'UniformOutput',false)),1,'first');
	if isempty(file_idx)
		continue
	end

	if ~isnan(str2double(this_line{2}))
		% interpret as temperature
		metadata.temperature(file_idx) = str2double(this_line{2});
	
	elseif strcmp(this_line{2},'decentralized')
		metadata.decentralized(file_idx:end) = true;
	elseif length(this_line) == 3 & ~isnan(str2double(this_line{3}))
		% interpret this as neuromodualtor + conc
		neuromodulator_name = this_line{2};
		neuromodualtor_conc = str2double(this_line{3});
		if ~isfield(metadata,neuromodulator_name)
			metadata.(neuromodulator_name) = zeros(n_files,1);
		end
		metadata.(neuromodulator_name)(file_idx:end) = neuromodualtor_conc;
	else
		
		keyboard
	end

end