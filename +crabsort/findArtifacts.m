% this function finds artifacts in the raw data
% and returns a logical vector when it thinks
% global (on all channels) artifacts are present

function artifacts = findArtifacts(obj, options)



data = obj.raw_data;

temp_channel =  find(strcmp(obj.common.data_channel_names,'temperature'));

if ~isempty(temp_channel)
	data(:,temp_channel) = [];
end

for i = 1:size(data,2)
	data(:,i) = abs(zscore(data(:,i)));
end


data = mean(data,2);


% split into two groups if possible
temp = kmeans(data,2);
V = sort([mean(data(temp==1)) mean(data(temp==2))]);



% show this
% close all
% figure('outerposition',[300 300 1200 900],'PaperUnits','points','PaperSize',[1200 900]); hold on
% clear ax
% for i = 1:size(obj.raw_data,2) 
% 	ax(i) = subplot(size(obj.raw_data,2),1,i); hold on
% 	plot(obj.raw_data(:,i))

% end


if V(2)/V(1) > 10
	thresh = mean(V);
	artifacts = data > thresh;
	%title(ax(1),' Artifacts!!!')


	% for i = 1
	% 	plot(ax(i),find(artifacts),obj.raw_data(artifacts,i),'o')
	% end

else
	%title(ax(1),'No artifacts')

	artifacts = 0*data;
	

end

S = round(options.dt/obj.dt);
artifacts = artifacts(1:S:end);





