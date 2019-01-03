function NNdelete(self, src, event)


channel = self.channel_to_work_with;

switch src.Text
case 'Delete NN data on this channel'
	if isempty(channel)
		return
	end
	self.common.NNdata(channel) = crabsort.NNdata(1);


	% try to stop anything being trained
	try
		cancel(self.workers(channel))
	catch
	end

	% update the NN display
	self.handles.ax.NN_accuracy(channel).String = 'No data';
	self.handles.ax.NN_status(channel).String = 'No data';
	self.handles.ax.has_automate(channel).BackgroundColor = [.9 .9 .9];

case 'Delete all NN data'
	self.common.NNdata = crabsort.NNdata(self.n_channels);
case 'Delete this channels NN'
	if isempty(channel)
		return
	end
	allfiles = dir([self.path_name 'network' filesep self.common.data_channel_names{channel},'*.mat']);
	for i = 1:length(allfiles)
		delete([allfiles(i).folder filesep allfiles(i).name])
	end

	% try to stop anything being trained
	try
		cancel(self.workers(channel))
	catch
	end

	% update the NN display
	self.handles.ax.NN_accuracy(channel).String = 'No data';
	self.handles.ax.NN_status(channel).String = 'No data';
	self.handles.ax.has_automate(channel).BackgroundColor = [.9 .9 .9];

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