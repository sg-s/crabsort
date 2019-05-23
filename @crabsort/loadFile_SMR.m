% crabsort plugin
% plugin_type = 'load-file';
% data_extension = 'smr';
% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% 
function loadFile_SMR(self,~,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


% read the file
[d,h] = smrlib.load(pathlib.join(self.path_name,self.file_name));

self.raw_data = cell2mat(d(~cellfun(@isstruct,d)));
dt = h{1}.sampleinterval;
self.metadata = h;


self.n_channels = size(self.raw_data,2);

self.builtin_channel_names = {};
for i = 1:self.n_channels
	self.builtin_channel_names{i} = strtrim(h{i}.title);
end



self.time = (1:length(self.raw_data))*dt*1e-6;
self.dt = mean(diff(self.time));
