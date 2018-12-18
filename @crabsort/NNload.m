
function net = NNload(self)

checkpoint_path = [self.path_name 'network' filesep self.common.data_channel_names{self.channel_to_work_with}];


saved_files = dir([checkpoint_path filesep '*.mat']);

n_iter = NaN(length(saved_files),1);

for i = 1:length(n_iter)

	if strcmp(saved_files(i).name,'trained_network.mat')
		continue
	end

	us = strfind(saved_files(i).name,'__');
	n_iter(i) = str2double(saved_files(i).name(us(1)+2:us(2)-1));

end

[~,idx]=max(n_iter);

load([saved_files(idx).folder filesep saved_files(idx).name])

