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
%           _       _        
%        __| | __ _| |_ __ _ 
%       / _` |/ _` | __/ _` |
%      | (_| | (_| | || (_| |
%       \__,_|\__,_|\__\__,_|
%                            
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

% if you're sure that all your ABF files in a single folder
% have the same format (same #channels, etc), then 
% set this to true
skip_abf_check = false;

% what are the possible names of nerves, units, channels?
channel_names = sort({'dgn','gpn','lgn','lpn','lvn','mgn','mvn','pdn','temperature','pyn','PD','AB','LPG','LP','IC','LG','MG','GM','PY','VD','Int1','DG','AM'});


% specify which units exist on which nerves

nerve2neuron.lpn = 'LP';
nerve2neuron.pdn = 'PD';
nerve2neuron.pyn = {'PY', 'LPG'};
nerve2neuron.lvn = {'LP','PD','PY'};
nerve2neuron.lgn = {'LG','MG'};
nerve2neuron.mvn = {'VD','IC','PY'};
nerve2neuron.dgn = {'DG','MG','AGR'};

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     _                       
%    | |_      ___ _ __   ___ 
%    | __|____/ __| '_ \ / _ \
%    | ||_____\__ \ | | |  __/
%     \__|    |___/_| |_|\___|
%                             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

% use MATLAB's built in t-SNE?
use_matlab_tsne = true;

