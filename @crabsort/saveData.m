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
    d = dbstack;
    cprintf('text',[mfilename ' called by ' d(2).name])
end

% early escape
if isempty(self.time) 
    return
end

% check if there is a .crabsort file already
file_name = joinPath(self.path_name, [self.file_name '.crabsort']);

data_channel_names = self.data_channel_names;
spikes = self.spikes;
channel_stage = self.channel_stage;

if exist(file_name,'file') == 2
    save(file_name,'spikes','data_channel_names','channel_stage','-append')
else
    save(file_name,'spikes','data_channel_names','channel_stage')
end