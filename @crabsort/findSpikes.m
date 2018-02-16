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

function findSpikes(self,Npeaks,event)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if nargin < 2
    Npeaks = '';
end

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if isempty(self.channel_to_work_with)
    return
end

% figure out which channel to work with
V = self.raw_data(:,self.channel_to_work_with);


if any(isnan(V))
    cprintf('red','\n[WARN] ')
    cprintf('NaNs found in voltage trace. Cannot continue.' )
    return
end


mpp = get(self.handles.spike_prom_slider,'Value');

v_cutoff = self.pref.V_cutoff;

mpd = ceil(self.pref.minimum_peak_distance/(self.dt*1e3));
mpw = ceil(self.pref.minimum_peak_width/(self.dt*1e3));

% first, find spikes in current window
if ~isa(Npeaks,'double')
    xlim = self.handles.ax.ax(self.channel_to_work_with).XLim;
    a = find(self.time >= xlim(1), 1, 'first');
    z = find(self.time <= xlim(2), 1, 'last');
    V2 = V(a:z);
    if ~self.handles.spike_sign_control.Value
        [~,loc] = findpeaks(-V2,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
    else
        [~,loc] = findpeaks(V2,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
    end
    self.handles.main_fig.Name = [self.file_name ' -- found ' oval(length(loc)) ' spikes in current view'];
    self.putative_spikes(:,self.channel_to_work_with) = 0;
    self.putative_spikes(loc+a-1,self.channel_to_work_with) = 1;
    drawnow
    if nargin > 2 && strcmp(event.EventName,'ContinuousValueChange')
        return
    end
end

% find peaks and remove spikes beyond v_cutoff
if ~isa(Npeaks,'double')
    if ~self.handles.spike_sign_control.Value
        [~,loc] = findpeaks(-V,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
        loc(V(loc) < -abs(v_cutoff)) = [];
    else
        [~,loc] = findpeaks(V,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
        loc(V(loc) > abs(v_cutoff)) = [];
    end
else
    % being called by train
    if ~self.handles.spike_sign_control.Value
        [~,loc] = findpeaks(-V,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw,'NPeaks',Npeaks);
    else
        [~,loc] = findpeaks(V,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw,'NPeaks',Npeaks);
    end
end

if self.verbosity
	cprintf('green','\n[INFO]')
    cprintf('text',[' found ' oval(length(loc)) ' spikes'])
end

self.handles.main_fig.Name = [self.file_name ' -- found ' oval(length(loc)) ' spikes'];


self.putative_spikes(:,self.channel_to_work_with) = 0;
self.putative_spikes(loc,self.channel_to_work_with) = 1;

if ~isa(Npeaks,'double')
    % after finding spikes, we should update the channel_stage
    self.channel_stage(self.channel_to_work_with) = 1;

end

if self.automatic
    return
end

% don't overwrite automate_info when called with Npeaks
% that's because train is using this to create a -ve dataset
if isa(Npeaks,'double')
    return
end



if self.watch_me && ~self.automatic


    % update the automate_info
    % find spikes is always the first step here, so we can safely overwrite everything 

    % create a description of the operations we just did 
    operation = struct;
    operation.property = {{'handles','spike_sign_control','Value'}, {'handles','spike_prom_slider','Max'}, {'handles','spike_prom_slider','Value'}};
    operation.value = {self.handles.spike_sign_control.Value, mpp, mpp};
    operation.method = @findSpikes;
    operation.data = [];

    self.common.automate_info(self.channel_to_work_with).operation = operation;

    % add this to the channel_order, so that automate can traverse the channels in the correct order
    if ~any(find(self.common.automate_channel_order == self.channel_to_work_with))
        self.common.automate_channel_order(end+1) = self.channel_to_work_with;
    end
                   
end

