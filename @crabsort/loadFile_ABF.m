% crabsort plugin
% plugin_type = 'load-file';
% data_extension = 'abf';
% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% 
function loadFile_ABF(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end


% read the file
[self.raw_data,dt,self.metadata] = abfload(joinPath(self.path_name,self.file_name));

self.n_channels = size(self.raw_data,2);
self.time = (1:length(self.raw_data))*dt*1e-6;

