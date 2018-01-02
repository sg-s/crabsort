%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% saves data in a .crabsort file 

function saveData(self)

% if self.verbosity > 5
%     cprintf('green','\n[INFO] ')
%     d = dbstack;
%     cprintf('text',[mfilename ' called by ' d(2).name])
% end

% early escape
if isempty(self.time) 
    return
end

% check if there is a .crabsort file already
file_name = joinPath(self.path_name, [self.file_name '.crabsort']);

data_channel_names = self.data_channel_names;
spikes = self.spikes;
channel_stage = self.channel_stage;

crabsort_obj = self;

% remove some stuff that shouldn't be saved
ignore_these = {'handles','raw_data','nerve2neuron','file_name','path_name','R','putative_spikes','installed_plugins','channel_to_work_with','build_number','version_name','pref'};

ignored_values = {};

for i = 1:length(ignore_these)
	ignored_values{i} = self.(ignore_these{i});
	crabsort_obj.(ignore_these{i}) = [];
end


if exist(file_name,'file') == 2
    save(file_name,'crabsort_obj')
else
    save(file_name,'crabsort_obj')
end

for i = 1:length(ignore_these)
	 self.(ignore_these{i}) = ignored_values{i};

end