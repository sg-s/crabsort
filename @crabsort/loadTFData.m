%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% loads all data needed for tensorflow, 
% over all files
% this also generates negative training data 
% on the fly 

function loadTFData(self,~,~)

allfiles = self.handles.tf.available_data.String{self.handles.tf.available_data.Value};

if ~iscell(allfiles)
	allfiles = {allfiles};
end



X = [];
Y = [];

for i = 1:length(allfiles)
	[this_X, this_Y] = self.getTFDataForThisFile(allfiles{i});
	X = [X; this_X];
	Y = [Y; this_Y];

end

% split evenly into test and training groups
X_train = X(:,1:2:end);
X_test = X(:,2:2:end);
Y_train = Y(:,1:2:end);
Y_test = Y(:,2:2:end);

self.common.tf.X = X_test;
self.common.tf.Y = Y_test;

p = pca(X_test);

n_groups = length(unique(Y(:)));
for i = 1:n_groups
	self.handles.tf.pca_plot(i).XData = p(Y_test==i,1);
	self.handles.tf.pca_plot(i).YData = p(Y_test==i,2);
end
L = self.common.tf.labels{self.channel_to_work_with};
legend(self.handles.tf.pca_plot(1:n_groups),L)


if exist(joinPath(self.path_name,'tensorflow'),'dir') ~=7
	mkdir(joinPath(self.path_name,'tensorflow'))
end

nerve_name = self.handles.tf.channel_picker.String{self.handles.tf.channel_picker.Value};

tf_model_dir = joinPath(self.path_name,'tensorflow',nerve_name);

if exist(tf_model_dir,'dir') ~=7
	mkdir(tf_model_dir)
end

savefast(joinPath(tf_model_dir,'spike_data.mat'),'X_test','X_train','Y_test','Y_train')

% copy the model
copyfile(joinPath(fileparts(fileparts(which(mfilename))),'tensorflow','*.py'),tf_model_dir)

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


