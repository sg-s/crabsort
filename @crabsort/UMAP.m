% crabsort plugin
% plugin_type = 'dim-red';
% plugin_dimension = 2;
%
%                 _                    _
%   ___ _ __ __ _| |__  ___  ___  _ __| |_
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% this is a plugin for crabsort.m
% uniform manifold approximation and projection (UMAP) for dimensionality reduction
% https://github.com/lmcinnes/umap
%
% created by Alec Hoyland 13:45 19 June 2019
% contact me at entropyvsenergy@posteo.de
%
% This plugin requires additional repositories and Python
% These instricutions assume that you are using Anaconda to manage your Python installation.
% If you are not, you can use pip or some other tool.
% 1. Install UMAP into a conda environment
% 	$ conda create --name crabsort-umap
% 	$ conda activate crabsort-umap
% 	$ conda install -c conda-forge umap-learn
% 	$ conda install h5py
% 2. Download condalab and add to your path
% 	$ git clone https://github.com/sg-s/condalab
% 	>> addpath path/to/condalab
% 3. Download umap-matlab-wrapper and add to your path
% 	$ git clone https://github.com/sg-s/umap-matlab-wrapper
% 	>> addpath path/to/umap-matlab-wrapper
% 	>> savepath
% 4. Configure condalab in MATLAB
% 	>> conda.init

function UMAP(self)

	if size(self.data_to_reduce,1) <= 2
		% do nothing
		self.R{self.channel_to_work_with} = self.data_to_reduce;
	else
		u = umap;
		R = u.fit(self.data_to_reduce);
		self.R{self.channel_to_work_with} = R(:,1:2)';
	end

end % function
