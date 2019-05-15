% checks if a given list
% of files is consequeitively numbered. 
% throws an error if not

function checkConsecutive(allfiles)



allfiles = {allfiles.name};

idx = all(~diff(char(allfiles(:))));
common_stub = allfiles{1}(1:find(~idx,1,'first')-1);

seq_idx = NaN(length(allfiles),1);

for i = 1:length(seq_idx)
	this_file = strrep(allfiles{i},common_stub,'');
	this_file = this_file(1:min(strfind(this_file,'.'))-1);
	seq_idx(i) = str2double(this_file);
end

assert(~any(isnan(seq_idx)),'Could not identify sequence in some files. Your files should be labelled with increasing numbers')
assert(max(diff(seq_idx))==1,'Some files in the sequence are missing. Stacking is not possible')
