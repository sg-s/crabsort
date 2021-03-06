% this is called internally by crabsort.consolidate 
% this reads .crabsort files and pulls out spikes from nerves

function data = readData(thisfile, options, data)


load([thisfile.folder filesep thisfile.name],'-mat','crabsort_obj')

if isempty(crabsort_obj.dt)
	corelib.cprintf('red',['Error when trying to read this data file: ' thisfile.name])
	return
end

disp(thisfile.name)

self = crabsort_obj;

% reconstruct mask
self.reconstructMaskFromIgnoreSection;

mask = min(self.mask,[],2);


if isempty(self.mask)
	return
end


data.T = self.raw_data_size(1)*self.dt;
SampleTime = options.dt:options.dt:data.T;
SampleTime = SampleTime(:);
mask = interp1((1:length(mask))*self.dt,mask,SampleTime);


data.mask = mask(:);



try
	if ~isempty(options.DataFun)
		self.file_name = strrep(thisfile.name,'.crabsort','');
		self.path_name = options.DataDir;
		self.loadFile;
		for j = 1:length(options.DataFun)
			
			
			variable_names = corelib.argOutNames(char(options.DataFun{j}));
			outputs = cell(1,length(variable_names));
			[outputs{:}] = options.DataFun{j}(self, options);

			for k = 1:length(variable_names)
				data.(strtrim(variable_names{k})) = outputs{k};
			end

		end
	end
catch
	corelib.cprintf('red',['Error when trying to read this data file: ' thisfile.name])
	return
end




% check if it is sorted
notsorted = crabsort.analysis.checkSortedSerial(thisfile,options.neurons,false);

if notsorted
	data.mask = data.mask*0;

	for j = 1:length(options.neurons)
		data.(options.neurons{j}) = [];
	end

	corelib.cprintf('red',['This file was not sorted: ' thisfile.name])
	return


end


if ~isstruct(self.spikes)
	% something wrong, abort
	data.mask = data.mask*0;

	corelib.cprintf('red',['Error when trying to read this data file: ' thisfile.name])
	return
end




% read out all the spiketimes
for j = 1:length(options.neurons)
	possible_spiketimes = {};
	possible_channels = {};


	this_neuron = options.neurons{j};
	data.([this_neuron '_channel'])  = categorical(NaN);

	fn = fieldnames(self.spikes);
	for k = 1:length(fn)
		neurons_here = fieldnames(self.spikes.(fn{k}));
		if any(strcmp(neurons_here,this_neuron))
			possible_spiketimes{end+1} = self.spikes.(fn{k}).(this_neuron);
			possible_channels{end+1} = fn{k};
		end
	end

	% does this neuron occur on multiple nerves?

	if length(possible_spiketimes) > 1
		% blindly pick the one with the most spikes
		[~,pick_me] = max(cellfun(@length,possible_spiketimes));
		spiketimes = possible_spiketimes{pick_me};
		possible_channels = possible_channels(pick_me);
	elseif length(possible_spiketimes) == 1
		spiketimes = possible_spiketimes{1};
	else
		spiketimes = [];
	end


	spiketimes  = round(spiketimes*self.dt*(1/options.dt));
	spiketimes = spiketimes*options.dt;
	data.(this_neuron) = spiketimes;
	if ~isempty(possible_channels)
		data.([this_neuron '_channel']) = categorical(possible_channels);
	end


end


clear self outputs 
