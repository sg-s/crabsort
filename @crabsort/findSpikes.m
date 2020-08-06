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

function findSpikes(self,Npeaks,~)

if self.verbosity > 9
    disp(mfilename)
end


if nargin < 2
    Npeaks = '';
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
if ~isa(Npeaks,'double')
    if ~self.sdp.spike_sign
        V = -V;
    end


    % use parallel pool to accelerate peak detection
    if self.raw_data_size(1) > 1e6
        NFragments = 1e3;
        V2 = [V; zeros(ceil(length(V)/NFragments)*NFragments - length(V),1)];
        V2 = reshape(V2,length(V2)/NFragments,NFragments);
       

        FragmentSize = size(V2,1);
        Shift = floor(FragmentSize/2);

        V3 = [V; zeros(ceil(length(V)/NFragments)*NFragments - length(V),1)];
        V3 = reshape(circshift(V3,Shift),FragmentSize,NFragments);

        loc2 = cell(NFragments,1);
        loc3 = cell(NFragments,1);


        parfor i = 1:NFragments
            [~,loc2{i}] = findpeaks(V2(:,i),'MinPeakHeight',MinPeakHeight,'MinPeakProminence',MinPeakProminence,'Threshold',Threshold,'MinPeakDistance',MinPeakDistance,'MinPeakWidth',MinPeakWidth,'MaxPeakWidth',MaxPeakWidth);
            loc2{i} = loc2{i}+(i-1)*FragmentSize;

            [~,loc3{i}] = findpeaks(V3(:,i),'MinPeakHeight',MinPeakHeight,'MinPeakProminence',MinPeakProminence,'Threshold',Threshold,'MinPeakDistance',MinPeakDistance,'MinPeakWidth',MinPeakWidth,'MaxPeakWidth',MaxPeakWidth);
            loc3{i} = loc3{i}+(i-1)*FragmentSize - Shift;

        end
        loc2 = vertcat(loc2{:});
        loc3 = vertcat(loc3{:});
        loc = unique(vertcat(loc2,loc3));
        loc(loc<1)=[];
    else
        [~,loc] = findpeaks(V,'MinPeakHeight',MinPeakHeight,'MinPeakProminence',MinPeakProminence,'Threshold',Threshold,'MinPeakDistance',MinPeakDistance,'MinPeakWidth',MinPeakWidth,'MaxPeakWidth',MaxPeakWidth);
    end


    loc(V(loc) > MaxPeakHeight) = [];
else
    % being called by train
    if ~self.sdp.spike_sign
        V = -V;
    end
    [~,loc] = findpeaks(V,'MinPeakHeight',MinPeakHeight,'MinPeakProminence',MinPeakProminence,'Threshold',Threshold,'MinPeakDistance',MinPeakDistance,'MinPeakWidth',MinPeakWidth,'MaxPeakWidth',MaxPeakWidth);
    loc(V(loc) > MaxPeakHeight) = [];
end


self.say(['found ' strlib.oval(length(loc)) ' spikes']);


self.putative_spikes(:,channel) = 0;
self.putative_spikes(loc,channel) = 1;

if ~isa(Npeaks,'double')
    % after finding spikes, we should update the channel_stage
    if any(self.putative_spikes(:,self.channel_to_work_with))
    	self.channel_stage(self.channel_to_work_with) = 1;
    else
    	self.channel_stage(self.channel_to_work_with) = 0;
    end

end
