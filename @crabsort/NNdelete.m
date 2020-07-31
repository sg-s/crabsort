function NNdelete(self, src, event)

if self.verbosity > 9
	disp(mfilename)
end


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

case 'Delete all NN data'
	self.common.NNdata = crabsort.NNdata(self.n_channels);
case 'Delete this channels NN'
	if isempty(channel)
		return
	end


	spikes_dir = fullfile(getpref('crabsort','store_spikes_here'),pathlib.lowestFolder(self.path_name));
	checkpoint_path = fullfile(spikes_dir,'network', self.common.data_channel_names{channel});
	allfiles = dir(fullfile(checkpoint_path,'*.mat'));

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

case 'Delete all nets'
	for i = 1:self.n_channels
		spikes_dir = fullfile(getpref('crabsort','store_spikes_here'),pathlib.lowestFolder(self.path_name));
		checkpoint_path = fullfile(spikes_dir,'network', self.common.data_channel_names{channel});
		allfiles = dir(fullfile(checkpoint_path,'*.mat'));
		for j = 1:length(allfiles)
			disp(['Deleting: ' [allfiles(j).folder filesep allfiles(j).name]])
			delete([allfiles(j).folder filesep allfiles(j).name])
		end
	end
otherwise 
	error('Unknown caller')
end