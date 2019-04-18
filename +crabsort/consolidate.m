% merges all .crabsort files and returns spike time info

function data = consolidate(varargin)


% options and defaults
options.DataDir = pwd;
options.dt = 1e-3; % 1 ms
options.nerves = {};
options.neurons = {};
options.stack = false;
options.DataFun = {};
options.ChunkSize = NaN; % seconds 

% validate and accept options
if mathlib.iseven(length(varargin))
	for ii = 1:2:length(varargin)-1
	temp = varargin{ii};
    if ischar(temp)
    	if ~any(find(strcmp(temp,fieldnames(options))))
    		disp(['Unknown option: ' temp])
    		disp('The allowed options are:')
    		disp(fieldnames(options))
    		error('UNKNOWN OPTION')
    	else
    		options.(temp) = varargin{ii+1};
    	end
    end
end
elseif isstruct(varargin{1})
	% should be OK...
	options = varargin{1};
else
	error('Inputs need to be name value pairs')
end

allfiles = dir([options.DataDir filesep '*.crabsort']);

if isempty(allfiles)
	error('No data found')
end

if ~iscell(options.DataFun)
	error('DataFun must be a cell array of function handles')
end

% load the common data
load([allfiles(1).folder filesep 'crabsort.common'],'-mat','common')


assert(~isempty(options.neurons),'neurons must be specified')




% figure out the experiment idx from the folder name
[~,exp_dir]=fileparts(options.DataDir);
exp_dir = str2double(strrep(exp_dir,'_',''));
assert(~isnan(exp_dir),'Could not determine experiment idx')

data = struct;
for i = length(allfiles):-1:1
	for j = 1:length(options.neurons)
		data(i).(options.neurons{j}) = [];
	end
	data(i).time_offset = 0;
	data(i).T = NaN;
	data(i).experiment_idx = exp_dir;
end



% check that all files are sorted
fatal = false;
for i = 1:length(allfiles)
	load([allfiles(i).folder filesep allfiles(i).name],'-mat','crabsort_obj')

	self = crabsort_obj;


	% check that the channel_stages for req nerves are OK
	if sum(self.channel_stage == 3) >= length(options.neurons)
	else
		corelib.cprintf('red',['Some channels not sorted on ' allfiles(i).name '\n'])
		fatal = true;
	end
end


if fatal
	error('Some files are not sorted')
else
	corelib.cprintf('green','All files sorted')
end

for i = 1:length(allfiles)
	load([allfiles(i).folder filesep allfiles(i).name],'-mat','crabsort_obj')

	disp(allfiles(i).name)

	self = crabsort_obj;



	for j = 1:length(options.neurons)
		possible_spiketimes = {};
		this_neuron = options.neurons{j};

		% find all possible places where this neuron could be
		if ~isstruct(self.spikes)
			keyboard
		end
		fn = fieldnames(self.spikes);
		for k = 1:length(fn)
			neurons_here = fieldnames(self.spikes.(fn{k}));
			if any(strcmp(neurons_here,this_neuron))
				possible_spiketimes{end+1} = self.spikes.(fn{k}).(this_neuron);
			end
		end

		% does this neuron occur on multiple nerves?

		if length(possible_spiketimes) > 1
			% blindly pick the one with the most spikes
			[~,pick_me] = max(cellfun(@length,possible_spiketimes));
			spiketimes = possible_spiketimes{pick_me};
		elseif length(possible_spiketimes) == 1
			spiketimes = possible_spiketimes{1};
		else
			spiketimes = [];
		end

		spiketimes  = round(spiketimes*self.dt*(1/options.dt));
		spiketimes = spiketimes*options.dt;
		data(i).(this_neuron) = spiketimes;


	end

	% reconstruct mask
	self.reconstructMaskFromIgnoreSection;

	mask = min(self.mask,[],2);

	S = round(options.dt/self.dt);
	mask = mask(1:S:end);
	data(i).mask = mask;

	
	

	data(i).T = self.raw_data_size(1)*self.dt;

	if i > 1
		data(i).time_offset = data(i-1).time_offset + data(i-1).T;
	end


	if ~isempty(options.DataFun)
		self.file_name = strrep(allfiles(i).name,'.crabsort','');
		self.path_name = allfiles(i).folder;
		self.loadFile;
		for j = 1:length(options.DataFun)
			
			
			variable_names = corelib.argOutNames(char(options.DataFun{j}));
			outputs = cell(1,length(variable_names));
			[outputs{:}] = options.DataFun{j}(self, options);

			for k = 1:length(variable_names)
				data(i).(strtrim(variable_names{k})) = outputs{k};
			end

		end
	end

	clear self outputs 

end





% parse metadata
metadata_exists = false;
m1 = [options.DataDir filesep 'metadata.txt'];
[~,folder_name]=fileparts(options.DataDir);
m2 = [options.DataDir filesep folder_name '.txt'];
if exist(m1,'file') == 2
	metadata = crabsort.parseMetadata(m1,allfiles);
	metadata_exists = true;
elseif exist(m2,'file') == 2
	metadata = crabsort.parseMetadata(m2,allfiles);
	metadata_exists = true;
else

end

if metadata_exists
	metadata_names = fieldnames(metadata);

	for j = 1:length(metadata_names)
		if ~isfield(data(1),metadata_names{j})
			data(1).(metadata_names{j}) = [];
		end
			
	end

	for i = 1:length(allfiles)
		for j = 1:length(metadata_names)
			data(i).(metadata_names{j}) = metadata.(metadata_names{j})(i);
		end
	end
end

fn = fieldnames(data);


if options.stack

	sdata = struct;

	for j = 1:length(fn)
		sdata.(fn{j}) = [];
	end



	for i = 1:length(data)


		for j = 1:length(fn)
			if any(strcmp(fn{j},options.neurons))
				sdata.(fn{j}) = [sdata.(fn{j}); data(i).time_offset+data(i).(fn{j})];
			elseif strcmp(fn{j},'T')
			elseif strcmp(fn{j},'time_offset')
			elseif strcmp(fn{j},'experiment_idx')
				sdata.experiment_idx = data(i).experiment_idx;
			else

				% check size
				this_variable = data(i).(fn{j});
				if length(this_variable) ~= length(data(i).mask)
					this_variable = this_variable*(data(i).mask*0 + 1);
				end
				sdata.(fn{j}) = [sdata.(fn{j}); this_variable];
				
			end

		end



	end
	
	



	data = sdata;



	if ~isnan(options.ChunkSize)
		disp('Chunking data...')


		n_rows = ceil(length(data.mask)*options.dt/options.ChunkSize);


		cdata = struct;

		% make matrices for every neuron 
		for i = 1:length(options.neurons)
			cdata.(options.neurons{i}) = NaN(1e3,n_rows);
		end



		for i = 1:n_rows
			a = (i-1)*options.ChunkSize;
			z = a + options.ChunkSize;


			for j = 1:length(options.neurons)
				these_spikes = data.(options.neurons{j});
				these_spikes = these_spikes(these_spikes >= a & these_spikes <= z);
				if length(these_spikes) > 1e3
					these_spikes = these_spikes(1:1e3);
				end
				cdata.(options.neurons{j})(1:length(these_spikes),i) = these_spikes;

			end
		end

		for j = 1:length(fn)
			if any(strcmp(fn{j},options.neurons))
			elseif strcmp(fn{j},'T')
			elseif strcmp(fn{j},'time_offset')
			elseif strcmp(fn{j},'experiment_idx')
				cdata.(fn{j})=  repmat(data.experiment_idx,n_rows,1);
			else

				cdata.(fn{j}) = data.(fn{j})(1:options.ChunkSize/options.dt:end);
				
			end

		end
	end

	data = cdata;


end


if ~isnan(options.ChunkSize)
	disp('Chunking data...')

	n_rows = ceil(length(vertcat(data.mask))*options.dt/options.ChunkSize);
	n_cols = ceil(options.ChunkSize/options.dt);

	cdata = struct;

	% make matrices for every neuron 
	for i = 1:length(options.neurons)
		cdata.(options.neurons{i}) = NaN(1e3,n_rows);
	end

	% make vectors for the metadata
	for j = 1:length(fn)
		if any(strcmp(fn{j},options.neurons))
		elseif strcmp(fn{j},'T')
		elseif strcmp(fn{j},'time_offset')
		elseif strcmp(fn{j},'experiment_idx')
			cdata.(fn{j}) = NaN(1,n_rows);
		else
			cdata.(fn{j}) = NaN(1,n_rows);
		end
	end


	row_idx = 1;
	for i = 1:length(data)
		data_idx = 1;

		goon = true;
		a = 0;
		z = a + options.ChunkSize;

		while goon
			for j = 1:length(options.neurons)
				these_spikes = data(i).(options.neurons{j});

				these_spikes = these_spikes(these_spikes >= a & these_spikes <= z);
				if length(these_spikes) > 1e3
					these_spikes = these_spikes(1:1e3);
				end

				these_spikes = these_spikes - a;

				cdata.(options.neurons{j})(1:length(these_spikes),row_idx) = these_spikes;

			end

			% also glom on the metadata
			data_dt = data(i).T/length(data(i).mask);
			aa = ceil(a/data_dt);
			if aa < 1; aa = 1; end
			zz = ceil(z/data_dt);
			if zz > length(data(i).mask);  zz = length(data(i).mask); end



			for j = 1:length(fn)
				if any(strcmp(fn{j},options.neurons))
				elseif strcmp(fn{j},'T')
				elseif strcmp(fn{j},'time_offset')
				elseif strcmp(fn{j},'experiment_idx')
					cdata.(fn{j})(row_idx) = data(i).experiment_idx;
				else
					if length(data(i).(fn{j})) == length(data(i).mask)
						cdata.(fn{j})(row_idx) = mean(data(i).(fn{j})(aa:zz));
					else
						cdata.(fn{j})(row_idx) = data(i).(fn{j});
					end
				end
			end

			a = z;
			z = a + options.ChunkSize;

			row_idx = row_idx + 1;

			if z > data(i).T
				goon = false;
			end

		end




	end

	% trim
	if row_idx < n_rows
		fn = fieldnames(cdata);
		for i = 1:length(fn)
			cdata.(fn{i}) = cdata.(fn{i})(:,1:row_idx);
		end
	end

	data = cdata;

end