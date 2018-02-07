%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% trains a neural network using 
% Tensorflow 

function train(self,~,~)

nerve_name = self.handles.tf.channel_picker.String{self.handles.tf.channel_picker.Value};
tf_model_dir = joinPath(self.path_name,'tensorflow',nerve_name);

self.handles.tf.train_button.String = 'Training...';
drawnow

curdir = pwd;
cd(tf_model_dir)
[e,o] = system('python test_tf_env.py');

if e
	% use condalab to switch to the correct environment 
	% and hope this works
	disp('Switching conda environment....')
	conda.setenv(self.pref.tf_env_name)
end


goon = true;


if length(self.common.tf.metrics) < self.channel_to_work_with
	self.common.tf.metrics(self.channel_to_work_with).accuracy = [];
	self.common.tf.metrics(self.channel_to_work_with).nsteps = [];
end

while goon

	self.handles.tf.fig.Name = 'TRAINING....';
	drawnow

	[e,o] = system(['python -c ' char(39) 'import tf_conv_net; tf_conv_net.train()' char(39)]);


	if e ~=0

		cd(curdir)
		disp(o)
		error('Something went wrong when training the model')
	end

	[accuracy, nsteps] = crabsort.parseTFOutput(o);

	if ~isfield(self.common.tf,'metrics')
		self.common.tf.metrics(self.channel_to_work_with).accuracy = [];
		self.common.tf.metrics(self.channel_to_work_with).nsteps = [];
	end

	self.common.tf.metrics(self.channel_to_work_with).accuracy = [self.common.tf.metrics(self.channel_to_work_with).accuracy accuracy];
	self.common.tf.metrics(self.channel_to_work_with).nsteps = [self.common.tf.metrics(self.channel_to_work_with).nsteps nsteps];

	% now use it to make predictions so we can update the plot 
	[e,o] = system(['python -c ' char(39) 'import tf_conv_net; tf_conv_net.predict()' char(39)]);
	if e
		cd(curdir)
		disp(o)
		error('Something went wrong when making predictions using the neural network')
	end


	% read the predictions 
	predictions = h5read(joinPath(tf_model_dir,'data.h5'),'/predictions');



	% update the graph
	for i = 1:max(self.common.tf.Y)
		these_correct = predictions(self.common.tf.Y == i) == i;

		% first make sure the Cdata is wellf formed
		self.handles.tf.pca_plot(i).CData = zeros(length(self.handles.tf.pca_plot(i).XData),3);
		self.handles.tf.pca_plot(i).CData(these_correct,2) = 1;
		self.handles.tf.pca_plot(i).CData(~these_correct,1) = 1;
	end

	self.handles.tf.accuracy_plot.XData = self.common.tf.metrics(self.channel_to_work_with).nsteps;
	self.handles.tf.accuracy_plot.YData = self.common.tf.metrics(self.channel_to_work_with).accuracy;



	drawnow;

	if self.common.tf.metrics(self.channel_to_work_with).accuracy > self.pref.tf_stop_accuracy
		goon = false;
	end

	if self.handles.tf.train_button.Value == 0
		goon = false;
	end

end

cd(curdir)

self.handles.tf.fig.Name = ['Training finished. Accuracy = ' oval(max(self.common.tf.metrics(self.channel_to_work_with).accuracy))];

self.handles.tf.train_button.Value = 0;
self.handles.tf.train_button.String = 'TRAIN';