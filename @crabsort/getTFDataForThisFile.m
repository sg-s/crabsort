%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% returns data for given file and loads into tensorflow

function [X, Y] = getTFDataForThisFile(self, thisfile)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end



if ~strcmp(self.file_name,thisfile)
	self.file_name = thisfile;
	self.loadFile;
end

% focus on the correct nerve
this_nerve = self.handles.tf.channel_picker.String{self.handles.tf.channel_picker.Value};
self.channel_to_work_with = find(strcmp(self.common.data_channel_names,this_nerve));

% check that there are spikes on this channel
[s, s_by_unit] = self.getSpikesOnThisNerve;

channel = self.channel_to_work_with;

% there should be a findSpikes and reduceDimensions operation
% in the automate info
all_methods = '';
try
	all_methods = cellfun(@func2str, {self.common.automate_info(channel).operation.method},'UniformOutput',false);
catch err
	for ei = 1:length(err)
        err.stack(ei)
    end
end
assert(~isempty(all_methods),'No methods in automate_info for this channel')
assert(any(strcmp(all_methods,'findSpikes')),'Automate info does not have a findSpikes operation. Sort spikes while "watch me" is checked')
assert(any(strcmp(all_methods,'reduceDimensionsCallback')),'Automate info does not have a reduceDimensionsCallback operation. Sort spikes while "watch me" is checked')


% assign properties for the findSpikes step
idx = find(strcmp(all_methods,'findSpikes'),1,'first');
operation = self.common.automate_info(channel).operation(idx);

for l = 1:length(operation.property)
	p = operation.property{l};
	setfield(self,p{:},operation.value{l});
end

% make sure that the data_reduction panel matches
% what was done. otherwise we won't get the correct
% data slice to train the network on 
idx = find(strcmp(all_methods,'reduceDimensionsCallback'),1,'first');
operation = self.common.automate_info(channel).operation(idx);

% assign properties for the dim red step
for l = 1:length(operation.property)
	if any(strcmp(operation.property{l},'method_control'))
		V = find(strcmp(self.handles.method_control.String,operation.value{l}));
		assert(~isempty(V),'[#445] Fatal error in getTFDataForThisFile: automate wants to perform a dimensionality reduction method that cant be found any more.')
		self.handles.method_control.Value = V;
	else
		p = operation.property{l};
		setfield(self,p{:},operation.value{l});
	end
end



% create the training and test data

% create the +ve training data
self.putative_spikes(:,channel) = s;
self.getDataToReduce;
X = self.data_to_reduce;

if size(s_by_unit,2) > 1
	s_by_unit = s_by_unit(find(sum(s_by_unit')),:);
	[~,Y] = max(s_by_unit');
else
	% only one unit
	Y = ones(1,length(X));
end

% now create some -ve training data
% halve the spike prominence and find spikes
new_spike_prom = self.common.automate_info(channel).operation(1).value{3};
new_spike_prom = new_spike_prom/2;

self.handles.spike_prom_slider.Max = new_spike_prom;
self.handles.spike_prom_slider.Value = new_spike_prom;

self.findSpikes(ceil(length(Y)/2)); % don't get in too much junk

% also pick some points at random, far from actual spikes so that we can augment the -ve training dataset
random_fake_spikes = find(circshift(s,floor(length(s)/3)));
dist_to_real_spikes = abs(random_fake_spikes - find(s));
too_close = dist_to_real_spikes < size(X,1)*2;
random_fake_spikes(too_close) = [];
if length(random_fake_spikes) >  size(X,2)/2
	random_fake_spikes = random_fake_spikes(1:floor(size(X,2)/2));
end
self.putative_spikes(random_fake_spikes,channel) = 1;

% remove the actual spikes
self.putative_spikes(logical(s),channel) = 0;

self.getDataToReduce;
X2 = self.data_to_reduce;

X = [X X2];
Y = [Y ones(1,size(X2,2))*(max(Y)+1)];

% if it's intracellular
temp = isstrprop(self.common.data_channel_names{channel},'upper');
if any(temp)

	% intracellular 
	default_neuron_name = self.common.data_channel_names{channel};
else
	default_neuron_name =  self.nerve2neuron.(self.common.data_channel_names{channel});
end

if iscell(default_neuron_name)
	default_names = [default_neuron_name, 'Noise'];
else
	default_names = {default_neuron_name, 'Noise'};
end
if ~isfield(self.common,'tf')
	self.common.tf.labels = {};
end
if isempty(self.common.tf.labels)
	self.common.tf.labels = {};
end
self.common.tf.labels{channel} = default_names;
