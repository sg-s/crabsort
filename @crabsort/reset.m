%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% resets crabsort to default state

function reset(self)


self.metadata = [];
self.n_channels = [];
self.raw_data = [];
self.data_channel_names = {};
self.time = [];
self.dt = [];
self.spikes = [];
self.putative_spikes = [];
self.channel_to_work_with = [];
self.channel_stage = [];
