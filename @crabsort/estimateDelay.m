%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% estimateDelay
% 
% computes delays between all channels
% and stores it in common
% this is meant to be run once on a dataset
% and the same delays are used again and again

function estimateDelay(self)

if ~any(isnan(self.common.delays(:)))
	% assume delays already computed, exit
	return
end

root_msg = 'Estimating delay b/w channels';

self.displayStatus(root_msg,true);

raw_data = self.raw_data;


delays = NaN(self.n_channels);
for i = 1:self.n_channels
	root_msg =[root_msg '.'];
	self.displayStatus(root_msg,true);


	A = zscore(raw_data(:,i));

	parfor j = 1:self.n_channels
		
		B = zscore(raw_data(:,j));
		delays(i,j) = finddelay(A,B);

	end
end



self.common.delays = delays;