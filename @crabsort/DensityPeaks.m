% % spikesort plugin
% plugin_type = 'cluster';
% plugin_dimension = 2; 
%
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% this plugin for spikesort uses the density peaks algorithm to automatically cluster spikes into 3 clusters (noise, B and A)
%
% 
% created by Srinivas Gorur-Shandilya. Contact me at http://srinivas.gs/contact/
% 
function DensityPeaks(s)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% unpack data

L = densityPeaks(s.R,'n_clusters',3,'percent',2);


% figure out which label is which
r = zeros(3,1);
for i = 1:3
	r(i) = mean(max(s.V_snippets(:,L==i)) - min(s.V_snippets(:,L==i)));
end

s.A = s.loc(L == find(r==max(r)));
s.N = s.loc(L == find(r==min(r)));
s.B = s.loc(L == find(r==median(r)));

% if we have to show the final solution, show it
if s.pref.show_dp_clusters
	temp = figure('Position',[0 0 800 800]); hold on
	c = lines(3);
	for i = 1:3
		plot(s.R(1,L==i),s.R(2,L==i),'+','Color',c(i,:))
	end
	prettyFig
	[~,idx]=sort(r,'descend');
	LL = {'A','B','noise'};
	legend(LL(idx))
	drawnow
	pause(1)
	delete(temp)
end