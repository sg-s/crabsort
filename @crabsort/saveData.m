%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% saves data in a .crabsort file 

function saveData(self)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
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
common_name = joinPath(self.path_name, 'common.crabsort');

crabsort_obj = self;

% remove some stuff that shouldn't be saved
ignore_these = {'handles','raw_data','nerve2neuron','file_name','path_name','R','putative_spikes','installed_plugins','channel_to_work_with','build_number','version_name','pref','channel_names','data_to_reduce','watch_me','time','verbosity','timer_handle','workers','auto_predict','automate_action'};

ignored_values = {};

for i = length(ignore_these):-1:1
	ignored_values{i} = self.(ignore_these{i});
	empty_obj = eval([class(crabsort_obj.(ignore_these{i})) '.empty()']);
	crabsort_obj.(ignore_these{i}) = empty_obj;
end


% now save the common items
common = self.common;
save(common_name,'common','-v7.3')

crabsort_obj.common = crabsort.common(self.n_channels);

try 
	if exist(file_name,'file') == 2
	    save(file_name,'crabsort_obj','-v7.3')
	else
	    save(file_name,'crabsort_obj','-v7.3')
	end
catch err
	if strcmp(err.identifier,'MATLAB:save:permissionDenied')
		warning('crabsort does not have permission to write to this folder, so cannot save .crabsort files. Make sure you have correct permissions and can write to this folder. ')
	end
end

for i = 1:length(ignore_these)
	 self.(ignore_these{i}) = ignored_values{i};
end

self.common = common;