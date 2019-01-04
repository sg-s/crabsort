% this method adds a data frame to the NNdata 

function self = addDataFrame(self,raw_data,file_idx,spiketimes,label_idx)


assert(isscalar(label_idx),'label_idx must be a scalar')
assert(isscalar(spiketimes),'spiketimes must be a scalar')
assert(isscalar(file_idx),'file_idx must be a scalar')
assert(isvector(raw_data),'raw_data must be a vector')

if isempty(self.raw_data)
	% all empty
	keyboard
else
	data_frame_size = size(self.raw_data,1);


end

% search in existing data for this
existing_data_frame = find(self.file_idx == file_idx & self.spiketimes == spiketimes);
if ~isempty(existing_data_frame)
	existing_data_frame = existing_data_frame(1);
	self.raw_data(:,existing_data_frame) = raw_data;
	self.file_idx(existing_data_frame) = file_idx;
	self.spiketimes(existing_data_frame) = spiketimes;
	self.label_idx(existing_data_frame) = label_idx;
else
	% new data frame, just add it
	self.raw_data(:,end+1) = raw_data;
	self.file_idx(end+1) = file_idx;
	self.spiketimes(end+1) = spiketimes;
	self.label_idx(end+1) = label_idx;
end

