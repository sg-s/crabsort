% opens a dataset, and a text file for the metadata
% usage
% crabsort.open('exp_#')
%
function datafolder = open(exp_name, silent)

if nargin == 1
	silent = false;
end



try
	data_loc =  getpref('crabsort','data_loc');
catch
	error('data_loc not set! ')
end

spikesfolder = getpref('crabsort','store_spikes_here');



datafolders = dir(fullfile(data_loc,'**',exp_name));

datafolders = datafolders([datafolders.isdir]);


if silent
	datafolder = datafolders(1);
	return
end

cd(datafolders(1).folder)

close all
self = crabsort;

assignin('base','self',self)

filelib.mkdir(fullfile(spikesfolder,exp_name))


metadata_file = dir(fullfile(spikesfolder,exp_name,'*.txt'));

if isempty(metadata_file)
	metadata_file = fullfile(spikesfolder,exp_name,[exp_name '.txt']);

	filelib.write(metadata_file,{'0000 baseline 1'})
	edit(metadata_file)

else
	edit(fullfile(metadata_file.folder,metadata_file.name))
end