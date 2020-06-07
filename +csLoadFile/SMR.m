% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% plugin to load .SMR files into crabsort.
% uses the smrlib toolbox
% that can be found here:
% https://github.com/sg-s/srinivas.gs_mtools/tree/master/%2Bsmrlib
% 
function S = SMR(self,~,~)


% read the file
[d,h] = smrlib.load(fullfile(self.path_name,self.file_name));

S.raw_data = cell2mat(d(~cellfun(@isstruct,d)));
dt = h{1}.sampleinterval;
S.metadata = h;


S.n_channels = size(S.raw_data,2);

S.builtin_channel_names = {};
for i = 1:S.n_channels
	S.builtin_channel_names{i} = strtrim(h{i}.title);
end


S.time = (1:length(S.raw_data))*dt*1e-6;
S.dt = mean(diff(S.time));
