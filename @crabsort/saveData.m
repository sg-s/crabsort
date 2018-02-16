%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% saves data in a .crabsort file 

function saveData(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% early escape
if isempty(self.time) 
    return
end

% saveData saves data to two different locations:
% local data that pertains to this file in a .crabsort file
% and common data that eprtains to all files in this folder
% to a file called common.crabsort in that folder 

% check if there is a .crabsort file already
file_name = joinPath(self.path_name, [self.file_name '.crabsort']);


crabsort_obj = self;

% remove some stuff that shouldn't be saved
ignore_these = {'common','handles','raw_data','nerve2neuron','file_name','path_name','R','putative_spikes','installed_plugins','channel_to_work_with','build_number','version_name','pref','channel_names','automatic','data_to_reduce','watch_me','time','verbosity'};

ignored_values = {};

for i = length(ignore_these):-1:1
	ignored_values{i} = self.(ignore_these{i});
	crabsort_obj.(ignore_these{i}) = [];
end


try 
	if exist(file_name,'file') == 2
	    savefast(file_name,'crabsort_obj')
	else
	    savefast(file_name,'crabsort_obj')
	end
catch err
	if strcmp(err.identifier,'MATLAB:save:permissionDenied')
		warning('crabsort does not have permission to write to this folder, so cannot save .crabsort files. Make sure you have correct permissions and can write to this folder. ')
	end
end

for i = 1:length(ignore_these)
	 self.(ignore_these{i}) = ignored_values{i};
end


% now save the common items
common = self.common;
file_name = joinPath(self.path_name, 'common.crabsort');
savefast(file_name,'common')