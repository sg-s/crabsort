% this test file pulls out all spikes from a 
% PD neuron from a set of files, and saves them
% together with the temperature the spike
% occured at
% 
% this demonstrates how to use crabsort programatically 

c = crabsort(false); c.path_name = pwd;

all_spikes = NaN(47,22939);
all_temp = NaN(22939,1);

allfiles = dir('*.abf');

idx = 1;

for i = 1:length(allfiles)

	disp(i)

	c.reset;
	c.file_name = allfiles(i).name;
	c.loadFile;

	spiketimes = c.spikes.pdn.PD*c.dt;

	Vs = c.getSnippets(4,c.spikes.pdn.PD);
	T = c.raw_data(c.spikes.pdn.PD,2);


	rm_these = diff(c.spikes.pdn.PD)*c.dt < (c.pref.t_before + c.pref.t_after)*1e-3;
	rm_these = circshift(rm_these,1) + rm_these;


	Vs = Vs(:,~rm_these);
	T = T(~rm_these);

	all_spikes(:,idx:idx+size(Vs,2)-1) = Vs;
	all_temp(idx:idx+size(Vs,2)-1) = T;


	idx = idx + size(Vs,2);


end

R = mctsne(all_spikes);

c = parula(100);

cidx = all_temp;
cidx = cidx - min(cidx);
cidx = cidx/max(cidx);
cidx = ceil(cidx*99) + 1;

C = c(cidx,:);

opacity = .4;
figure('outerposition',[0 0 1000 1000],'PaperUnits','points','PaperSize',[1000 1000]); hold on
scatter(R(1,:),R(2,:),128,C,'filled','Marker','o','MarkerFaceAlpha',opacity,'MarkerEdgeAlpha',opacity);