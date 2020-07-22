% crabsort.database.build
% builds a database in a xlsx sheet
% 
function T = build(varargin)


try
	data_loc =  getpref('crabsort','data_loc');
catch
	error('data_loc not set! ')
end



% get a list of all experiments in the crabsort spikes folder
spikesfolder = getpref('crabsort','store_spikes_here');
all_exps = dir(spikesfolder);
all_exps = all_exps([all_exps.isdir]);

try
	T = readtable(fullfile(spikesfolder, 'crabsort-db.xlsx'));
catch
	T = crabsort.database.makeRow;
end


options.cacheTemperature = false;



options = corelib.parseNameValueArguments(options,varargin{:});


% get all experiments in spikes folder
spikesfolder = getpref('crabsort','store_spikes_here');



% first, consolidate all the data



VariableNames = T.Properties.VariableNames;

% first check that everything is cached nicely
for i = length(all_exps):-1:1


	if strcmp(all_exps(i).name(1),'.')
		continue
	end

	this_exp = all_exps(i).name;

	


	% check if a row exists for this exp name
	if ~any(strcmp(T.ExpName,this_exp))
		T = [T; crabsort.database.makeRow];	
		T.ExpName{end} = this_exp;
	end


	row = find(strcmp(T.ExpName,this_exp));



	% check if every entry is complete in this row. if so, skip and move on
	skip_check = [~isempty(T{row,'ExpName'}{1}); ~isempty(T{row,'experimenter'}{1}); ~isempty(T{row,'TempCached'}{1}); ~isempty(T{row,'TempChannelExists'}{1}) ; ~isempty(T{row,'DataMissing'}{1}) ;  T{row,'NumPDSpikes'}~=-1 ;  (T{row,'NumLPSpikes'}~=-1) ; T{row,'SortProgress'}~=-1 ; ~isempty(T{row,'PDLPUsable'}{1})];

	if all(skip_check)
		continue
	end




	disp(this_exp)


	% load common
	clearvars common
	load(fullfile(spikesfolder,this_exp,'crabsort.common'),'-mat')
	% sanitize common type
	for j = 1:length(common.data_channel_names)
		if isempty(common.data_channel_names{j})
			common.data_channel_names{j} = '';
		end
	end

	% is there a temperature channel?
	if isempty(T{row,'TempChannelExists'}{1})
		% need to check this...
		
		if any(strcmp(common.data_channel_names,'temperature'))
			T(row,'TempChannelExists') = {'TRUE'};
		else
			T(row,'TempChannelExists') = {'FALSE'};
		end

	end


	if options.cacheTemperature
		crabsort.database.cacheTemperature(this_exp)
	end

	% has temperature been cached
	if isempty(T{row,'TempCached'}{1})
		if exist(fullfile(spikesfolder,this_exp,[this_exp '.metadata']),'file') == 2
			T(row,'TempCached') = {'TRUE'};
		end

	end

	

	alldata{i} = crabsort.consolidate(this_exp,'neurons',{'PD','LP'},'ParseMetadata',true);


	% fill in other fields
	if isempty(T{row,'experimenter'}{1})
		try
			T(row,'experimenter') = {char(alldata{i}(1).experimenter)};
		catch
			warning([this_exp 'did not have experimenter metadata'])
		end
	end

	
	if  T{row,'NumPDSpikes'}<0
		T(row,'NumPDSpikes') = {length(vertcat(alldata{i}.PD))};
	end

	if  T{row,'NumLPSpikes'}<0
		T(row,'NumLPSpikes') = {length(vertcat(alldata{i}.LP))};
	end

	if isempty(T{row,'DataMissing'}{1})
		% find out the number of data files
		datafolders = dir(fullfile(data_loc,'**',['*' this_exp '*']));
		datafolders = datafolders([datafolders.isdir]);

		if length(datafolders) < 1
			T{row,'DataMissing'} = {'TRUE'};
		else
			T{row,'DataMissing'} = {'FALSE'};
		end

	end


	if T{row,'SortProgress'}<0
		% we can only compute this if the data is not missing
		if strcmp(T{row,'DataMissing'}{1},'FALSE')
			datafolders = dir(fullfile(data_loc,'**',['*' this_exp '*']));
			datafolders = datafolders([datafolders.isdir]);
			datafolder = fullfile(datafolders(1).folder,datafolders(1).name);

			% count all the data files
			nfiles = length(dir(fullfile(datafolder,'*.abf'))) + length(dir(fullfile(datafolder,'*.smr'))) + length(dir(fullfile(datafolder,'*.crab')));

			% now count the # of fully sorted data files
			nsorted = 0;
			for j = 1:length(alldata{i})
				if any(alldata{i}(j).mask)
					nsorted = nsorted + 1;
				end
			end

			T{row,'SortProgress'} = (nsorted/nfiles)*100;


		end

	end


	if isempty(T{row,'PDLPUsable'}{1})
		if any(ismember({'PD','pdn'},common.data_channel_names)) && any(ismember({'LP','lpn','gpn','lvn'},common.data_channel_names)) 
			T{row,'PDLPUsable'} = {'TRUE'};
		else
			T{row,'PDLPUsable'} = {'FALSE'};
		end
	end

	

	% comments are allowed to be empty...so load silently


	% get info about channels
	for j = 1:length(VariableNames)
		if any(strcmp(common.data_channel_names,VariableNames{j}))
			T{row,VariableNames{j}} = 1;
		end
	end
	



end


	% save table
	writetable(T,fullfile(spikesfolder, 'crabsort-db.xlsx'));
