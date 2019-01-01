function NNdelete(self, src, event)


channel = self.channel_to_work_with;

switch src.Text
case 'Delete NN data on this channel'
	if isempty(channel)
		return
	end
	self.common.NNdata(channel) = crabsortNNdata(1);

case 'Delete all NN data'
	self.common.NNdata = crabsortNNdata(self.n_channels);
case 'Delete this channels NN'
	if isempty(channel)
		return
	end
	allfiles = dir([self.path_name 'network' filesep self.common.data_channel_names{channel},'*.mat']);
	for i = 1:length(allfiles)
		delete([allfiles(i).folder filesep allfiles(i).name])
	end
case 'Delete all nets'
	for i = 1:self.n_channels
		allfiles = dir([self.path_name 'network' filesep self.common.data_channel_names{i},'*.mat']);
		for j = 1:length(allfiles)
			delete([allfiles(j).folder filesep allfiles(j).name])
		end
	end
otherwise 
	error('Unknown caller')
end