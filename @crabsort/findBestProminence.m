%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% attempt to automatically determine the best prominence
% to detect spikes 

function best_prom = findBestProminence(self)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


% figure out which channel to work with
V = self.raw_data(:,self.channel_to_work_with);

% assume +ve spikes

% find max range in sliding windows 
all_prom = linspace(max(V)/10,2*max(V),100);
n_spikes = NaN*all_prom;

mpd = 1;
mpw = 1;

N = floor((length(V)*self.dt)*20); % don't expect more than 20Hz on average

for i = length(all_prom):-1:1
	[~,loc] = findpeaks(V,'MinPeakProminence',all_prom(i),'MinPeakDistance',mpd,'MinPeakWidth',mpw,'NPeaks',N);
	n_spikes(i) = length(loc);
	disp(n_spikes(i))
	if n_spikes(i) == N
		break
	end
end

% measure variability on changing the tresh
variability = abs(n_spikes - circshift(n_spikes,5))./n_spikes;
[~,idx] = min(variability);
best_prom = all_prom(idx);