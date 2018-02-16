%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% preferences file for crabsort
% crabsort has many preferences, and, instead of wasting time building more and more UI to handle them, all preferences are in this text file (like in Sublime Text)
% this is meant to be read by readPref
% 
% created by Srinivas Gorur-Shandilya at 4:52 , 16 September 2015. Contact me at http://srinivas.gs/contact/
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 _ _           _             
%              __| (_)___ _ __ | | __ _ _   _ 
%             / _` | / __| '_ \| |/ _` | | | |
%            | (_| | \__ \ |_) | | (_| | |_| |
%             \__,_|_|___/ .__/|_|\__,_|\__, |
%                        |_|            |___/ 
%            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot_line_width = .5;

putative_spike_colour = 'm';
embedded_spike_colour = 'g';

fs = 14; 					% UI font size
fw = 'bold'; 				% UI font weight

% context width: window around the spike to show when clicked on in a reduced representation
context_width = .2; % seconds. 

% what spike markers do you want to use to display
% sorted spikes? 
spike_markers = {'o','x','d','p','h','+','s'};

% to focus on one channel, other channels can be made
% transparent. what opacity level do you want? 
data_opacity = .5; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                _ _        
%       ___ _ __ (_) | _____ 
%      / __| '_ \| | |/ / _ \
%      \__ \ |_) | |   <  __/
%      |___/ .__/|_|_|\_\___|
%          |_|               
%           _      _            _   _             
%        __| | ___| |_ ___  ___| |_(_) ___  _ __  
%       / _` |/ _ \ __/ _ \/ __| __| |/ _ \| '_ \ 
%      | (_| |  __/ ||  __/ (__| |_| | (_) | | | |
%       \__,_|\___|\__\___|\___|\__|_|\___/|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                           
% Spike snippet width
t_before = 5; 		% in ms
t_after = 4; 		% in ms

minimum_peak_prominence = 'auto'; 	% minimum peak prominence for peak detection. you can use 'auto' or you can also specify a scalar value

% minimum width of spikes, in ms
minimum_peak_width = 0; 

% minimum distance b/w spikes, in ms	
minimum_peak_distance = .5; 

% ignore peaks beyond this limit 
V_cutoff = -Inf; 						


% this setting specifies an upper bound on 
% how far back in time (or forward) we look 
% for spikes in other channels
max_relative_time = 1; % seconds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  _                             __ _               
% | |_ ___ _ __  ___  ___  _ __ / _| | _____      __
% | __/ _ \ '_ \/ __|/ _ \| '__| |_| |/ _ \ \ /\ / /
% | ||  __/ | | \__ \ (_) | |  |  _| | (_) \ V  V / 
%  \__\___|_| |_|___/\___/|_|  |_| |_|\___/ \_/\_/  
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       

% You installed tensorflow in a conda environment:
% what's the environment called?
% (If you didn't, Tensorflow + crabsort won't work 
% -- reinstall in its own environment)
tf_env_name = 'tensorflow';

% how many neurons in the first convolutional layer?
tf_conv1_N = 32;

%size of kernel in 1st conv layer
tf_conv1_K = 15;

%pool size of 1st pool layer
tf_pool1_N = 2;

% stride step of pool1 
tf_pool1_S = 2;

% number of neurons in dense layer
tf_dense_N = 100;
tf_dropout_rate = 0.4;

% how many steps? how many epochs
tf_nsteps = 1000;
tf_nepochs = 2;

% when should training stop? at what
% level of accuracy? 
tf_stop_accuracy = 0.95;

% how accurate should a tensorflow model
% be so that automate uses it instead of 
% whatever program is has memorized? 
tf_predict_accuracy = 0.95;