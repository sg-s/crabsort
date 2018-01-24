%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% reads the preference file and updates prefs
% within object  

function reloadPreferences(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

self.pref = readPref(fileparts(fileparts(which(mfilename))));
    