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

putative_spike_colour = 'm';
embedded_spike_colour = 'g';

fs = 14; 					% UI font size
fw = 'bold'; 				% UI font weight

% context width: window around the spike to show when clicked on in a reduced representation
context_width = .2; % seconds. 

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


minimum_peak_width = 1; % minimum width of spikes, in ms

minimum_peak_distance = 1; % minimum distance b/w spikes, in ms	


V_cutoff = -Inf; 						% ignore peaks beyond this limit 

invert_V = false; 					% sometimes, it is easier to find spikes if you invert V


% this setting specifies an upper bound on 
% how far back in time (or forward) we look 
% for spikes in other channels
max_relative_time = 1; % seconds