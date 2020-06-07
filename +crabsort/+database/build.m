% crabsort.database.buil
% builds a database in a xls sheet
% 
function T = build(rebuild_db, OnlyThisExp)

% get all experiments in spikes folder
spikesfolder = getpref('crabsort','store_spikes_here');

if nargin == 0 || isempty(rebuild_db)
	rebuild_db = true;
end


T = readtable([spikesfolder filesep 'crabsort-db.xlsx']);

if ~rebuild_db

	return
end

channels = {'temperature','lvn','lpn','pdn','LP','PD','gpn'};



allexps = dir(spikesfolder);

if nargin < 2
	OnlyThisExp = {allexps.name};
end

for i = 1:length(channels)
	C.(channels{i}) = logical(zeros(length(allexps),1));
end



try
	data_loc =  getpref('crabsort','data_loc');
catch
	error('data_loc not set! ')
end


% first get a list of all folders in the data
all_data_folders = filelib.getAllFolders(data_loc);

% some other fields
C.exp_name = cell(length(allexps),1);
C.data_missing = logical(zeros(length(allexps),1));
C.PDLPUsable = logical(zeros(length(allexps),1));
C.NumSpikes = zeros(length(allexps),1);
C.SortedTime = zeros(length(allexps),1);


% check if we have a table already
if exist('T','var')
	C = table2struct(T,'ToScalar',true);
end

for i = 1:length(allexps)


	if ~strcmp(allexps(i).name,OnlyThisExp)
		continue
	end
	

	disp(allexps(i).name)

	if strcmp(allexps(i).name(1),'.')
		continue
	end

	if ~isdir([allexps(i).folder filesep allexps(i).name])
		continue
	end

	C.exp_name{i} = allexps(i).name;

	% load the common file from there
	clearvars common 

	commonfile = [allexps(i).folder filesep allexps(i).name filesep 'crabsort.common'];

	if exist(commonfile,'file') ~= 2
		% disp('Missing common file!')
		% disp(allexps(i).name)
		continue
	end

	load(commonfile,'-mat')

	for j = 1:length(channels)
		if  any(strcmp(common.data_channel_names,channels{j}))
			C.(channels{j})(i) = true;
		end
	end


	% see if we can locate the data 
	possible_data_folders = all_data_folders(filelib.find(all_data_folders,allexps(i).name));
	if isempty(possible_data_folders)
		C.data_missing(i) = true;
	else
		data_idx = find(strcmp(pathlib.lowestFolder(possible_data_folders),allexps(i).name),1,'first');
		if isempty(data_idx)
			C.data_missing(i) = true;
		else
			C.data_missing(i) = false;
		end
	end


	% if there is a temperature channel, we should have that in the metadata
	if C.temperature(i) && ~C.data_missing(i)
		crabsort.database.cacheTemperature(allexps(i).name)

	end

	if nargin == 2
		data = crabsort.consolidate(allexps(i).name,'neurons',{'PD','LP'},'ParseMetadata',false,'RebuildCache',true);
	else
		data = crabsort.consolidate(allexps(i).name,'neurons',{'PD','LP'},'ParseMetadata',false,'RebuildCache',false);
	end
	for j = 1:length(data)
		C.NumSpikes(i) = C.NumSpikes(i) + length(data(j).PD) + length(data(j).LP);
		C.SortedTime(i) = C.SortedTime(i) + sum(data(j).mask)*1e-3;
	end


end


C.PDLPUsable = (C.LP | C.lpn | C.gpn) & (C.pdn | C.PD);

T = struct2table(C);

T = movevars(T,'exp_name','before',channels{1});

writetable(T,[spikesfolder filesep 'crabsort-db.xlsx'])
