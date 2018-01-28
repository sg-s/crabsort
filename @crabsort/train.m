%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% trains a neural network using 
% Tensorflow 

function train(self,~,~)

% check that there is data that we can use to train 
if length(self.tf_data) < self.channel_to_work_with
	error('Nothing to train because there is no data here')
end

if  isempty(self.tf_data(self.channel_to_work_with))
	error('No data to train. ')
end

self.handles.popup.String = 'Training neural network...';
self.handles.popup.Visible = 'on';

self.handles.tf_trainbar = waitbar(0, 'Training network...');
self.handles.tf_trainbar.Name = 'Training Neural network...';


waitbar(.1, self.handles.tf_trainbar, 'Setting up model...')

% create the model name if not set and copy the model over
get_model_name = false;
if length(self.tf_model_name) < self.channel_to_work_with
	get_model_name = true;
else
	if isempty(self.tf_model_name{self.channel_to_work_with})
		get_model_name = true;
	end
end

if get_model_name
	self.askUserForTFModelName;
end

% is there a model with this name in tensorflow/models? 
tf_model_dir = joinPath(self.tf_folder,'models',self.tf_model_name{self.channel_to_work_with});
if ~(exist(tf_model_dir) == 7)
	% make the folder
	mkdir(tf_model_dir)

	% copy the python folders over 
	copyfile(joinPath(self.tf_folder,'*.py'),tf_model_dir)

end


waitbar(.1, self.handles.tf_trainbar, 'Exporting data...')

% create the training and test data
X = self.tf_data(self.channel_to_work_with).X;
Y = self.tf_data(self.channel_to_work_with).Y;


X_train = X(:,1:2:end);
Y_train = Y(1:2:end);

X_test = X(:,2:2:end);
Y_test = Y(2:2:end);

savefast(joinPath(tf_model_dir,'spike_data.mat'),'X_test','X_train','Y_test','Y_train')

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

% use condalab to switch to the correct environment 
conda.setenv(self.pref.tf_env_name)


% save current dir
curdir = pwd;

% switch to tf_model_dir
cd(tf_model_dir)




try

	% train the model and report the accuracy 
	
	[e,o] = system(['python -c ' char(39) 'import tf_conv_net; tf_conv_net.train()' char(39)]);

catch
	cd(curdir)
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

	waitbar(i/10, self.handles.tf_trainbar, acc_mess)

end


self.handles.popup.Visible = 'off';
close(self.handles.tf_trainbar)

cd(curdir)