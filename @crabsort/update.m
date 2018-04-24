%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
%
% update.m
% https://github.com/sg-s/crabsort
% Srinivas Gorur-Shandilya

function update(self,~,~)

update_these = {'conda','manualCluster','mctsne','crabsort'};

original_dir = pwd;

for i = 1:length(update_these)

	try

		cd(fileparts(which(update_these{i})));

		system('git stash')
		system('git pull')

	catch
		disp(['Something went wrong while updating :' update_these{i}])
	end
end

cd(original_dir)