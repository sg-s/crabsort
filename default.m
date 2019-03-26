%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% preferences file for crabsort
% crabsort has many preferences, and, instead of wasting time building more and more UI to handle them, all preferences are in this text file (like in Sublime Text)
% this is meant to be read by corelib.readPref
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

% should we bother measuring delays b/w channels?
skip_delays = false;

% how many seconds around artifacts should we ignore? 
artifact_buffer = 1; % second


% if you're sure that all your ABF files in a single folder
% have the same format (same #channels, etc), then 
% set this to true
skip_abf_check = false;

% what are the possible names of nerves, units, channels?
channel_names = sort({'ogn','dgn','gpn','lgn','lpn','lvn','mgn','mvn','pdn','temperature','pyn','PD','AB','LPG','LP','IC','LG','MG','GM','PY','VD','Int1','DG','AM'});


% specify which units exist on which nerves
nerve2neuron.ogn = {'MCN1','OMN'};
nerve2neuron.PY = 'PY';
nerve2neuron.LP = 'LP';
nerve2neuron.PD = 'PD';
nerve2neuron.lpn = 'LP';
nerve2neuron.pdn = 'PD';
nerve2neuron.pyn = {'PY', 'LPG'};
nerve2neuron.lvn = {'LP','PD','GM'};
nerve2neuron.lgn = {'LG','MG'};
nerve2neuron.mvn = {'VD','IC','PY'};
nerve2neuron.dgn = {'DG','GM','AGR'};
nerve2neuron.dvn = {'DG','MG','AGR'};

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
spike_markers = {'o','x','p','h','+','s','d'};

% to focus on one channel, other channels can be made
% transparent. what opacity level do you want? 
data_opacity = .5; 


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

