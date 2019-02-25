%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% reads the preference file and updates prefs
% within object  

function reloadPreferences(self,~,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


self.pref = corelib.readPref(fileparts(fileparts(which(mfilename))));
    