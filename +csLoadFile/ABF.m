
% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% 
function S = ABF(self,~,~)


% read the file
[S.raw_data,dt,S.metadata] = filelib.abfload(pathlib.join(self.path_name,self.file_name),'doDispInfo',false);



S.time = (1:length(S.raw_data))*dt*1e-6;


% populate builtin_channel_names
S.builtin_channel_names = S.metadata.recChNames;