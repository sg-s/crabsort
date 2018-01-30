%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% trains a neural network using 
% Tensorflow 

function train(self,~,~)

% check that there are spikes on this channel
[s, s_by_unit] = self.getSpikesOnThisNerve;

if sum(s) < 200
	error('Not enough spikes on this channel to train a network.')
end

channel = self.channel_to_work_with;

% there should be a findSpikes and reduceDimensions operation
% in the automate info
all_methods = '';
try
	all_methods = cellfun(@func2str, {self.common.automate_info(channel).operation.method},'UniformOutput',false);
catch
end
assert(~isempty(all_methods),'No methods in automate_info for this channel')
assert(any(strcmp(all_methods,'findSpikes')),'Automate info does not have a findSpikes operation. Sort spikes while "watch me" is checked')
assert(any(strcmp(all_methods,'reduceDimensionsCallback')),'Automate info does not have a reduceDimensionsCallback operation. Sort spikes while "watch me" is checked')

% make sure that the data_reduction panel matches
% what was done. otherwise we won't get the correct
% data slice to train the network on 
idx = find(strcmp(all_methods,'reduceDimensionsCallback'),1,'first');
operation = self.common.automate_info(channel).operation(idx);
% assign all properties
for l = 1:length(operation.property)
	p = operation.property{l};
	setfield(self,p{:},operation.value{l});
end


self.handles.popup.String = 'Training neural network...';
self.handles.popup.Visible = 'on';

self.handles.tf_trainbar = waitbar(0, 'Training network...');
self.handles.tf_trainbar.Name = 'Training Neural network...';


waitbar(.05, self.handles.tf_trainbar, 'Setting up model...')

% create the model name if not set and copy the model over
get_model_name = false;
if length(self.tf_model_name) < channel
	get_model_name = true;
else
	if isempty(self.tf_model_name{channel})
		get_model_name = true;
	end
end

if get_model_name
	self.askUserForTFModelName;
end

% is there a model with this name in tensorflow/models? 
tf_model_dir = joinPath(self.tf_folder,'models',self.tf_model_name{channel});
if ~(exist(tf_model_dir) == 7)
	% make the folder
	mkdir(tf_model_dir)

	% copy the python folders over 
	copyfile(joinPath(self.tf_folder,'*.py'),tf_model_dir)

end


waitbar(.1, self.handles.tf_trainbar, 'Exporting data...')



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


% halve the spike prominence and find spikes
new_spike_prom = self.common.automate_info(channel).operation(1).value{3};
new_spike_prom = new_spike_prom/2;


self.handles.spike_prom_slider.Value = new_spike_prom;

self.findSpikes(ceil(length(Y)/2)); % don't get in too much junk

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
if isempty(self.tf_labels)
	self.tf_labels = {};
end
self.tf_labels{channel} = default_names;

X_train = X(:,1:2:end);
Y_train = Y(1:2:end);

X_test = X(:,2:2:end);
Y_test = Y(2:2:end);


savefast(joinPath(tf_model_dir,'spike_data.mat'),'X_test','X_train','Y_test','Y_train')

waitbar(.15, self.handles.tf_trainbar, 'Updating parameters...')
% update the parameters 
fn = fieldnames(self.pref);
L = {};
for i = length(fn):-1:1
	if length(fn{i}) < 4
		continue
	end
	if strcmp(fn{i}(1:3),'tf_')
		L{i} = [fn{i} ' = ' mat2str(self.pref.(fn{i}))];
	end
end
L{end+1} = ['tf_model_dir = "' tf_model_dir '"'];
L{end+1} = ['tf_snippet_dim = ' mat2str(size(X,1))];
L{end+1} = ['tf_N_classes = ' mat2str(max(Y))];
lineWrite(joinPath(tf_model_dir,'params.py'),L)

waitbar(.2, self.handles.tf_trainbar, 'Testing environment...')

curdir = pwd;
cd(self.tf_folder)
[e,o] = system('python test_tf_env.py');

if e
	% use condalab to switch to the correct environment 
	% and hope this works
	disp('Switching conda environment....')
	conda.setenv(self.pref.tf_env_name)
end


% switch to tf_model_dir
cd(tf_model_dir)


[e,o] = system(['python -c ' char(39) 'import tf_conv_net; tf_conv_net.train()' char(39)]);

if e ~=0

	cd(curdir)
	disp(o)
	self.handles.popup.Visible = 'off';
	close(self.handles.tf_trainbar)
	error('Something went wrong when training the model')
end


% if it ran once, it should be good
for i = 1:self.pref.tf_nepochs
	[e,o] = system(['python -c ' char(39) 'import tf_conv_net; tf_conv_net.train()' char(39)]);

	a = strfind(o,'accuracy');
	z = strfind(o,'loss');

	acc_mess = o(a:z-4);

	waitbar(i/self.pref.tf_nepochs, self.handles.tf_trainbar, acc_mess)

end


self.handles.popup.Visible = 'off';
close(self.handles.tf_trainbar)

cd(curdir)