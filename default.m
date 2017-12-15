%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% preferences file for crabsort
% spikesort has many preferences, and, instead of wasting time building more and more UI to handle them, all preferences are in this text file (like in Sublime Text)
% this is meant to be read by readPref
% 
% created by Srinivas Gorur-Shandilya at 4:52 , 16 September 2015. Contact me at http://srinivas.gs/contact/
% 



%% ~~~~~~~~~~~~~~~~~  GENERAL  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

useFastBandPass = true; 	% use a fast, FFT-based bandPass? 

%% ~~~~~~~~~~~~~~~~~  DISPLAY  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

putative_spike_colour = 'm';
embedded_spike_colour = 'g';
A_spike_colour = 'r';
B_spike_colour = 'b';

% display preferences
marker_size = 5; 			% how big the spike indicators are
show_r2 = false;			% show r2 in firing rate plot
fs = 14; 					% UI font size
fw = 'bold'; 				% UI font weight
plot_control = true; 		% should spikesort plot the control signals instead of the stimulus?

% UI
smart_scroll = true; 				% intelligently scroll so we keep # visible spikes constant 
% context width: window around the spike to show when clicked on in a reduced representation
context_width = .2; % seconds. 

% density peaks automatic cluster visualization 
show_dp_clusters = true;

%% ~~~~~~~~~~~~~~~~~  LFP, RASTER AND FIRING RATE PLOTS  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

show_individual_trials_stimulus = false;
show_individual_trials_LFP = false;
show_individual_trials_firing_rate = false;

% firing rate estimation
show_firing_rate_r2 = false; 	% show r-square of firing rates?
firing_rate_dt = 1e-2; % time step for firing rate estimation 
firing_rate_window_size = 3e-2; % window size for firing rate convolution

%% ~~~~~~~~~~~~~~~~~  SPIKE DETECTION AND RESOLUTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% spike detection
t_before = 20; 		% should be an integer, in units of data samples
t_after = 25; 		% should be an integer, in units of data samples 
minimum_peak_prominence = 'auto'; 	% minimum peak prominence for peak detection. you can use 'auto' or you can also specify a scalar value
minimum_peak_width = 1;
minimum_peak_distance = 1; 			% how separated should the peaks be?
V_cutoff = -1; 						% ignore peaks beyond this limit 
band_pass = [5 .5]; 			% in ms. fluctuations longer than the first element are ignored, and fluctuations shorter than the second element are averaged across. 
invert_V = false; 					% sometimes, it is easier to find spikes if you invert V

% spike resolution
remove_doublets = true;				% resolve doublet peaks, which are very likely AB or BA, not AA or BB
doublet_distance = 40; 				% how far out should you look for doublets? in units of timestep


% artifact removal 
remove_artifacts = 'off'; % 'on' or 'off'. 
template_width = 100;
template_amount = 0; 
use_off_template = false;
use_on_template = false;

%% ~~~~~~~~~~~~~~~~~  tSNE parameters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

no_dims = 2;
init_dims = 10;
perplexity = 60;
theta = .5;
max_iter = 400;

multicore_tsne_path = '~/anaconda3/bin'; % change this to the path where MultiCoreTSNE is installed 


