% this script is an example of how 
% to use crabsort programatically
% (without the GUI)
% here, we are using it to pull all
% spiketimes from an already sorted
% dataset

c = crabsort(false); c.path_name = pwd;

allfiles = dir('*.abf');


% get the total length of the vector 
% we need to create by scanning all the files

N = 0;

for i = 1:length(allfiles)

	c.reset;
	c.file_name = allfiles(i).name;
	c.loadFile;

	N = N + length(c.time);

end

PD_spikes = sparse(N,1);
LP_spikes = sparse(N,1);
PY_spikes = sparse(N,1);

temperature = NaN(N,1);

offset = 0;

for i = 1:length(allfiles)

	c.reset;
	c.file_name = allfiles(i).name;
	c.loadFile;

	PD = c.spikes.pdn.PD + offset;
	PD_spikes(PD) = 1;

	LP = c.spikes.lpn.LP + offset;
	LP_spikes(LP) = 1;

	PY = c.spikes.pyn.PY + offset;
	PY_spikes(PY) = 1;


	temperature(offset + 1:offset + length(c.raw_data)) = c.raw_data(:,2);

	offset =  offset + length(c.time);
end

R = mctsne(all_spikes);

c = parula(100);

all_temp = removePointDefects(all_temp);

cidx = all_temp;
cidx = cidx - min(cidx);
cidx = cidx/max(cidx);
cidx = ceil(cidx*99) + 1;

C = c(cidx,:);

opacity = .4;
figure('outerposition',[0 0 1000 1000],'PaperUnits','points','PaperSize',[1000 1000]); hold on
scatter(R(1,:),R(2,:),128,C,'filled','Marker','o','MarkerFaceAlpha',opacity,'MarkerEdgeAlpha',opacity);