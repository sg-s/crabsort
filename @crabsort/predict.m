%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% use a trained Tensorflow network
% to make predictions about spikes 

function predict(self,~,~)

tf_model_dir = '';

try
	tf_model_dir = joinPath(self.tf_folder,'models',self.tf_model_name{self.channel_to_work_with});
catch
end

if isempty(tf_model_dir)
	error('No neural network associated with this channel.')
end

% check that this folder exists
if exist(tf_model_dir,'dir') == 7
else
	error('No TF model found. Train the model first')
end


curdir = pwd;
cd(self.tf_folder)
[e,~] = system('python test_tf_env.py');

if e
	% use condalab to switch to the correct environment 
	% and hope this works
	disp('Switching conda environment....')
	conda.setenv(self.pref.tf_env_name)
end
cd(curdir)


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
	self.getDataToReduce;

	% pass through TensorFlow
	X_test = self.data_to_reduce;
	Y_test = ones(size(self.data_to_reduce,2),1);


	savefast(joinPath(tf_model_dir,'spike_data.mat'),'X_test','Y_test')


	curdir = pwd;
	cd(tf_model_dir)

	[e,o] = system(['python -c ' char(39) 'import tf_conv_net; tf_conv_net.predict()' char(39)]);
	cd(curdir)
	if e
		disp(o)
		error('Something went wrong when making predictions using the neural network')
	end
	

	% read the predictions 
	predictions = h5read(joinPath(tf_model_dir,'data.h5'),'/predictions');

	labels = self.tf_labels{channel};

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



else
	% we already have spikes
	keyboard
end

