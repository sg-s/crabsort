%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% resets crabsort to default state

function reset(self,wipe_all)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

self.raw_data = [];
self.time = [];
self.dt = [];
self.spikes = [];
self.metadata = [];
self.putative_spikes = [];
self.channel_to_work_with = [];
self.channel_stage = [];
self.n_channels = [];
	
if nargin < 2
	wipe_all = true;
end

if wipe_all 	
	self.common.data_channel_names = {};	
end