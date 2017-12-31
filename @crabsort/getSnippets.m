%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% gets snippets from the raw data

function V_snippets = getSnippets(self,channel, spiketimes)



V_snippets = [];


if nargin == 2
	spiketimes = self.putative_spikes(:,channel);
	spiketimes = find(spiketimes);

	if isempty(spiketimes)
		return
	end
end

V = self.raw_data(:,channel);

% cut out the snippets 
before = ceil(self.pref.t_before/(self.dt*1e3));
after = ceil(self.pref.t_after/(self.dt*1e3));

V_snippets = NaN(before+after,length(spiketimes));
if spiketimes(1) < before+1
    spiketimes(1) = [];
    V_snippets(:,1) = []; 
end
if spiketimes(end) + after+1 > length(V)
    spiketimes(end) = [];
    V_snippets(:,end) = [];
end
for i = 1:length(spiketimes)
    V_snippets(:,i) = V(spiketimes(i)-before+1:spiketimes(i)+after);
end




