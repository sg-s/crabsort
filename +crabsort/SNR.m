% measures the signal-to-noise ratio in sorted data

function data = SNR(varargin)



% options and defaults
options.DataDir = pwd;
options.MakePlot = false;
options.UseCache = true;

% validate and accept options
options = corelib.parseNameValueArguments(options,varargin{:});

allfiles = dir([options.DataDir filesep '*.crabsort']);


if isempty(allfiles)
	N = 1;
	data.file_name = categorical(repmat(NaN,10*N,1));
	data.path_name = categorical(repmat(NaN,10*N,1));
	data.nerve_name = categorical(repmat(NaN,10*N,1));
	data.neuron_name = categorical(repmat(NaN,10*N,1));
	data.SNR = (repmat(NaN,10*N,1));
	return
end

% hash these files
for i = length(allfiles):-1:1
	H{i} = hashlib.md5hash([allfiles(i).folder filesep allfiles(i).name],'File');
end

H = hashlib.md5hash([H{:}]);
if exist([allfiles(1).folder filesep H '.snr'],'file') == 2 && options.UseCache
	load([allfiles(1).folder filesep H '.snr'],'-mat')

else


	% load the common data
	try
		load([allfiles(1).folder filesep 'crabsort.common'],'-mat','common')
	catch
		% common does not exist, abort
		N = length(allfiles);
		data.file_name = categorical(repmat(NaN,10*N,1));
		data.path_name = categorical(repmat(NaN,10*N,1));
		data.nerve_name = categorical(repmat(NaN,10*N,1));
		data.neuron_name = categorical(repmat(NaN,10*N,1));
		data.SNR = (repmat(NaN,10*N,1));
		return
	end





	data = struct;
	N = length(allfiles);
	data.file_name = categorical(repmat(NaN,10*N,1));
	data.path_name = categorical(repmat(NaN,10*N,1));
	data.nerve_name = categorical(repmat(NaN,10*N,1));
	data.neuron_name = categorical(repmat(NaN,10*N,1));
	data.SNR = (repmat(NaN,10*N,1));


	temp_data = struct;
	for i = 1:N
		temp_data(i).file_name = categorical({''});
		temp_data(i).path_name = categorical({''});
		temp_data(i).nerve_name = categorical({''});
		temp_data(i).neuron_name = categorical({''});
		temp_data(i).SNR = NaN;
	end



	% load all the data into the data structure
	% in parallel
	parfor i = 1:N
		temp_data(i) = crabsort.analysis.measureSNR(allfiles(i), temp_data(i));
	end



	% reshape
	data.SNR = vertcat(temp_data.SNR);
	data.neuron_name = vertcat(temp_data.neuron_name);
	data.nerve_name = vertcat(temp_data.nerve_name);
	data.file_name = vertcat(temp_data.file_name);
	data.path_name = vertcat(temp_data.path_name);

	% clean up
	rm_this = isnan(data.SNR);

	data.SNR(rm_this) = [];
	data.neuron_name(rm_this) = [];
	data.nerve_name(rm_this) = [];
	data.file_name(rm_this) = [];
	data.path_name(rm_this) = [];


	% save it
	save([allfiles(1).folder filesep H '.snr'],'data')
end

if ~options.MakePlot
	return
end

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on


unique_nerves = unique(data.nerve_name);
L = {};
idx = 1;
for i = 1:length(unique_nerves)
	unique_neurons = unique(data.neuron_name(data.nerve_name == unique_nerves(i)));
	for j = 1:length(unique_neurons)
		use_this = data.nerve_name == unique_nerves(i) & data.neuron_name == unique_neurons(j);

		y = data.SNR(use_this);
		plot(0*y+idx+.01*randn(length(y),1),y,'o');
		L{end+1} = [char(unique_nerves(i)) '/' char(unique_neurons(j))];

		text(idx-.1,max(y)*1.2,strlib.oval(max(y)),'FontSize',24)
		idx = idx + 1;
	end


end

ylabel('SNR')
ax = gca;
set(gca,'YScale','log','YGrid','on','XLim',[0 idx],'XTick',[1:idx-1],'XTickLabel',L,'YLim',[ax.YLim(1)*.75 ax.YLim(2)*1.5])
title(char(data.file_name(1)),'interpreter','none')
figlib.pretty()
