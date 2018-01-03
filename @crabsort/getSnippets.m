%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% gets snippets from the raw data

function V_snippets = getSnippets(self,channel, spiketimes)

if nargin == 2
	spiketimes = self.putative_spikes(:,channel);
	spiketimes = find(spiketimes);

	if isempty(spiketimes)

		return

	end
end

before = ceil(self.pref.t_before/(self.dt*1e3));
after = ceil(self.pref.t_after/(self.dt*1e3));

V_snippets = zeros(before+after,length(spiketimes));


V = self.raw_data(:,channel);

for i = 1:length(spiketimes)

	if spiketimes(i) < before+1
		continue
	end

	if spiketimes(i) + after+1 > length(V)
		continue
	end

    V_snippets(:,i) = V(spiketimes(i)-before+1:spiketimes(i)+after);
end



