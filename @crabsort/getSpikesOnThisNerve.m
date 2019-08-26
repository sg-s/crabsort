
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% gets spiketimes of already sorted spikes
% from current channel's nerve 

function [spiketimes, st_by_unit] = getSpikesOnThisNerve(self)

if self.verbosity > 9
	disp(mfilename)
end

spiketimes = 0*self.putative_spikes(:,self.channel_to_work_with);
st_by_unit = zeros(length(spiketimes),1);

try
	this_nerve_spikes = self.spikes.(self.common.data_channel_names{self.channel_to_work_with});
catch err
	for ei = 1:length(err)
        err.stack(ei)
    end
	return
end

fn = fieldnames(this_nerve_spikes);
st_by_unit = zeros(length(spiketimes),length(fn));


for i = 1:length(fn)
	st_by_unit(this_nerve_spikes.(fn{i}),i) = 1;
	spiketimes(this_nerve_spikes.(fn{i})) = 1;
end