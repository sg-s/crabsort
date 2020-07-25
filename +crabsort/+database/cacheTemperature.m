function cacheTemperature(exp_name)


spikesfolder = getpref('crabsort','store_spikes_here');

if nargin == 0
	% do it for all of them
	allexps = dir(spikesfolder);
	for i = 1:length(allexps)

		if strcmp(allexps(i).name(1),'.')
			continue
		end

		crabsort.database.cacheTemperature(allexps(i).name)

	end



	return

end

disp(exp_name)

% first check if there is even a temperature channel
load(fullfile(spikesfolder,exp_name,'crabsort.common'),'-mat')
if ~any(strcmp(common.data_channel_names,'temperature'))
	disp('No temperature channel')
	return
end


try
	data_loc =  getpref('crabsort','data_loc');
catch
	error('data_loc not set! ')
end




% figure out type of data
allfiles = dir(fullfile(spikesfolder,exp_name));
ext = '';
for i = 1:length(allfiles)
	if strcmp(allfiles(i).name(1),'.')
		continue
	end

	[~,~,thisext] = fileparts(allfiles(i).name);
	if strcmp(thisext,'.crabsort')
		[~,~,ext]=fileparts(strrep(allfiles(i).name,'.crabsort',''));
	end
end

assert(~isempty(ext),['Could not determine data ext for: ' exp_name])

% check if a .metadata file exists in spikes
metadata_file = fullfile(spikesfolder,exp_name,[exp_name,'.metadata']);
if exist(metadata_file,'file') == 2

	disp('Metadata file exists...')


else


	disp('Missing metadata file. Searching for source data...')

	datafolders = dir(fullfile(data_loc,'**',['*' exp_name '*']));
	datafolders = datafolders([datafolders.isdir]);

	if isempty(datafolders)
		warning(['Could not locate date for ' exp_name])
	else


		metadata = struct;


		% do all the datafolders
		for j = 1:length(datafolders)


			datafolder = fullfile(datafolders(j).folder,datafolders(j).name);



			% get the temperature
			self = crabsort(false);
			options = struct;
			options.dt = 1; % 1 second resolution for temperature should be good enough
			self.path_name = datafolder;

			allfiles = dir(fullfile(datafolder,['*' ext]));


			for i = 1:length(allfiles)

				corelib.textbar(i,length(allfiles))

				self.file_name = allfiles(i).name;

				self.loadFile;
				
				metadata(i).file_name = allfiles(i).name;
				metadata(i).temperature = crabsort.getTemperature(self,options);
				

			end
	
		end

		% save
		disp('Saving...')
		save(metadata_file,'metadata')
	end
end