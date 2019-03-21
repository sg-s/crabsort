% this function finds artifacts in the raw data
% and returns a logical vector when it thinks
% global (on all channels) artifacts are present

function artifacts = findArtifacts(obj, options)

data = self.raw_data;

temp_channel =  find(strcmp(obj.common.data_channel_names,'temperature'));

if ~isempty(temp_channel)
	data(:,temp_channel) = [];
end

for i = 1:size(data,2)

	data(:,i) = zscore(data(:,i));
end

data = mean(data,2);
data = abs(data);
data = zscore(data);

artifacts = data>3;

S = round(options.dt/obj.dt);
artifacts = artifacts(1:S:end);