% crabsort plugin
% plugin_type = 'load-file';
% data_extension = 'mat';
% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% 
function S = MAT(self,~,~)


% read the file
data = load(fullfile(self.path_name,self.file_name),'-mat');

fn = fieldnames(data);
fn = setdiff(fn,{'file'});

S.builtin_channel_names = {};
S.raw_data = {};
S.dt = {};
for i = 1:length(fn)
	if isfield(data.(fn{i}),'values')
		S.builtin_channel_names = [S.builtin_channel_names; data.(fn{i}).title];
		S.raw_data = [S.raw_data; data.(fn{i}).values];
		S.dt = [S.dt; data.(fn{i}).interval];
	end
end

% resample all data so that they have the same interval
max_dt = max([S.dt{:}]);
all_sizes = [];
for i = 1:length(S.dt)
	time = (1:length(S.raw_data{i}))*S.dt{i};
	actual_time = max_dt:max_dt:max(time);
	S.raw_data{i} = interp1(time, S.raw_data{i}, actual_time);
	all_sizes(i) = length(S.raw_data{i});
end

% the raw data is not going to all have the same size, so let's fix that
min_size = min(all_sizes);
for i = 1:length(S.dt)
	S.raw_data{i} = S.raw_data{i}(1:min_size);
end

S.raw_data = vertcat(S.raw_data{:})';

% populate builtin_channel_names

S.metadata = data.file;
S.time = (1:length(S.raw_data))*max_dt;
S.dt = max_dt;
