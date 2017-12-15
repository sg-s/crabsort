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

function findSpikes(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% figure out which channel to work with
V = self.raw_data(:,self.channel_to_work_with);


if any(isnan(V))
    cprintf('red','\n[WARN] ')
    cprintf('NaNs found in voltage trace. Cannot continue.' )
    return
end

if get(self.handles.prom_auto_control,'Value')
    %guess some nice value
    mpp = nanstd(V)/2;
else
    mpp = get(self.handles.spike_prom_slider,'Value');
end


% if ~isempty(s.A) || ~isempty(s.B)
%     return
% end



% mpd = pref.minimum_peak_distance;
% mpw = pref.minimum_peak_width;
v_cutoff = self.pref.V_cutoff;

mpd = 1;
mpw = 1;

% find peaks and remove spikes beyond v_cutoff
if self.pref.invert_V
    [~,loc] = findpeaks(-V,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
    loc(V(loc) < -abs(v_cutoff)) = [];
else
    [~,loc] = findpeaks(V,'MinPeakProminence',mpp,'MinPeakDistance',mpd,'MinPeakWidth',mpw);
    loc(V(loc) > abs(v_cutoff)) = [];
end


if self.verbosity
	cprintf('green','\n[INFO]')
    cprintf('text',[' found ' oval(length(loc)) ' spikes'])
end


% cut out the snippets 
self.R = [];
if ~isempty(loc)

    V_snippets = NaN(self.pref.t_before+self.pref.t_after,length(loc));
    if loc(1) < self.pref.t_before+1
        loc(1) = [];
        V_snippets(:,1) = []; 
    end
    if loc(end) + self.pref.t_after+1 > length(V)
        loc(end) = [];
        V_snippets(:,end) = [];
    end
    for i = 1:length(loc)
        V_snippets(:,i) = V(loc(i)-self.pref.t_before+1:loc(i)+self.pref.t_after);
    end

    s.V_snippets = V_snippets;
end

self.loc = loc;
