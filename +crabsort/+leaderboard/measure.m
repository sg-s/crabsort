% measures SNR in all folders in the current directory
% 
function data = measure(look_here, UseCache)

if nargin == 0
	look_here = pwd;
	UseCache = true;
elseif nargin == 1
	UseCache = true;
end

all_folders = filelib.getAllFolders(look_here);

for i = length(all_folders):-1:1


	data(i).file_name = categorical(NaN(10,1));
	data(i).path_name = categorical(NaN(10,1));
	data(i).nerve_name = categorical(NaN(10,1));
	data(i).neuron_name = categorical(NaN(10,1));
	data(i).SNR = (NaN(10,1));

	if length(dir([all_folders{i} filesep '*.crabsort'])) == 0
		continue
	end


	data(i) = crabsort.SNR('DataDir',all_folders{i}, 'UseCache', UseCache);
end