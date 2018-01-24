%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% makes a raster using all sorted spikes 

function makeRaster(self,~,~)


if isempty(self.spikes)
	return
end


figure('outerposition',[30 30 1501 900],'PaperUnits','points','PaperSize',[1501 900]); hold on

spiketimes = {};
L = {};

fn = fieldnames(self.spikes);


for i = 1:length(fn)
	this_nerve = fn{i};

	idx = find(strcmp(self.data_channel_names,fn{i}));

	fn2 = fieldnames(self.spikes.(fn{i}));
	for j = 1:length(fn2)
		this_neuron = fn2{j};

		spiketimes{end+1} = self.spikes.(fn{i}).(fn2{j});
		L{end+1} = [fn{i} '/' fn2{j}];
	end
end

% NaN-pad to make all the things the same size 
N = max(cellfun(@(x) length(x), spiketimes));
for i = 1:length(spiketimes)
	if length(spiketimes{i}) < N
		temp = NaN(N,1);
		temp(1:length(spiketimes{i})) = spiketimes{i};
		spiketimes{i} = temp;
	end
end

raster(spiketimes{:},'deltat',self.dt);

set(gca,'YTick',(1:length(L)) - .5,'YTickLabel',L)

prettyFig();
