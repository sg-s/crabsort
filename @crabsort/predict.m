%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% use a trained Tensorflow network
% to make predictions about spikes 

function predict(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

nerve_name = self.common.data_channel_names{self.channel_to_work_with};
tf_model_dir = joinPath(self.path_name,'tensorflow',nerve_name);


if isempty(tf_model_dir)
	error('No neural network associated with this channel.')
end

% check that this folder exists
if exist(tf_model_dir,'dir') == 7
else
	error('No TF model found. Train the model first')
end


curdir = pwd;
cd(tf_model_dir)
[e,~] = system('python test_tf_env.py');

if e
	% use condalab to switch to the correct environment 
	% and hope this works
	disp('Switching conda environment....')
	conda.setenv(self.pref.tf_env_name)
end


channel = self.channel_to_work_with;

if  self.channel_stage(channel) < 3
	% find spikes using automate_info


	% findSpikes is always the first operation 
	operation = self.common.automate_info(channel).operation(1);
	self.current_operation = 1;


	% assign all properties
	for l = 1:length(operation.property)
		p = operation.property{l};
		setfield(self,p{:},operation.value{l});
	end

	self.findSpikes;

else
	already_sorted_spikes = self.getSpikesOnThisNerve;
	if ~any(already_sorted_spikes)
		return
	end

	self.putative_spikes(:,self.channel_to_work_with) = already_sorted_spikes;

end

% make sure that the data_reduction panel matches
% what was done. otherwise we won't get the correct
% data slice to train the network on 

% there should be a findSpikes and reduceDimensions operation
% in the automate info
all_methods = '';
try
	all_methods = cellfun(@func2str, {self.common.automate_info(channel).operation.method},'UniformOutput',false);
catch
end
assert(~isempty(all_methods),'No methods in automate_info for this channel')
assert(any(strcmp(all_methods,'reduceDimensionsCallback')),'Automate info does not have a reduceDimensionsCallback operation. Sort spikes while "watch me" is checked')


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

self.getDataToReduce;

self.handles.main_fig.Name = 'Using Tensorflow to classify spikes...';
drawnow


% pass through TensorFlow
X_test = self.data_to_reduce;
Y_test = ones(1,size(self.data_to_reduce,2));

% normalize
X_test = X_test/self.common.tf.mean_peak(channel);

savefast(joinPath(tf_model_dir,'spike_data.mat'),'X_test','Y_test')


cd(tf_model_dir)

[e,o] = system(['python -c ' char(39) 'import tf_conv_net; tf_conv_net.predict()' char(39)]);
cd(curdir)
if e
	disp(o)
	error('Something went wrong when making predictions using the neural network')
end


% read the predictions 
predictions = h5read(joinPath(tf_model_dir,'data.h5'),'/predictions');

labels = self.common.tf.labels{self.channel_to_work_with};

putative_spikes = find(self.putative_spikes(:,channel));
this_nerve = self.common.data_channel_names{channel};

for i = 1:length(labels)
	if strcmp(labels{i},'Noise')
		continue
	end
	these_spikes = putative_spikes(predictions == i);
	self.spikes.(this_nerve).(labels{i}) = these_spikes;
end


self.handles.found_spikes(self.channel_to_work_with).XData = [];
self.handles.found_spikes(self.channel_to_work_with).YData = [];

self.showSpikes;

% mark it as done
self.channel_stage(self.channel_to_work_with) = 3; 




cd(curdir)

self.handles.main_fig.Name = [self.file_name '   DONE!'];

% no putative spikes
self.putative_spikes(:,self.channel_to_work_with) = 0;