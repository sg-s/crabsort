%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
%
% findSpikes.m
% part of the crabsort package
% 
% created by Srinivas Gorur-Shandilya at 8:58 , 20 November 2015. Contact me at http://srinivas.gs/contact/
% 

function findSpikes(self,Parameters,Npeaks)

arguments
    self (1,1) crabsort
    Parameters (:,1) struct = struct([])
    Npeaks (1,1) = round(self.raw_data_size(1));
end


% copy the parameters into sdp
for i = 1:length(Parameters)
    self.sdp.(Parameters(i).Name) = Parameters(i).Value;
end


if isempty(self.channel_to_work_with)
    return
else
    channel = self.channel_to_work_with;
end

% figure out which channel to work with
V = self.raw_data(:,channel).*self.mask(:,channel);


if any(isnan(V))
    corelib.cprintf('red','\n[WARN] ')
    corelib.cprintf('NaNs found in voltage trace. Cannot continue.' )
    return
end


MinPeakHeight = self.sdp.MinPeakHeight;
MinPeakProminence = self.sdp.MinPeakProminence;
Threshold = self.sdp.Threshold;
MinPeakDistance = ceil(self.sdp.MinPeakDistance/(self.dt*1e3));
MinPeakWidth = ceil(self.sdp.MinPeakWidth/(self.dt*1e3));
MaxPeakWidth = ceil(self.sdp.MaxPeakWidth/(self.dt*1e3));
MaxPeakHeight = self.sdp.MaxPeakHeight;

% find peaks and remove spikes beyond v_cutoff
if ~self.sdp.spike_sign
    V = -V;
end

[~,loc] = findpeaks(V,'MinPeakHeight',MinPeakHeight,'MinPeakProminence',MinPeakProminence,'Threshold',Threshold,'MinPeakDistance',MinPeakDistance,'MinPeakWidth',MinPeakWidth,'MaxPeakWidth',MaxPeakWidth,'Npeaks',Npeaks);
loc(V(loc) > MaxPeakHeight) = [];


self.say(['found ' strlib.oval(length(loc)) ' spikes']);


self.putative_spikes(:,channel) = 0;
self.putative_spikes(loc,channel) = 1;



if  Npeaks == round(self.raw_data_size(1))
    % Npeaks is not being called by train, so 
    % after finding spikes, we should update the channel_stage
    if any(self.putative_spikes(:,self.channel_to_work_with))
    	self.channel_stage(self.channel_to_work_with) = 1;
    else
    	self.channel_stage(self.channel_to_work_with) = 0;
    end

end
