% crabsort plugin
% plugin_type = 'cluster';
% plugin_dimension = 2; 
% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% allows you to manually cluster a reduced-to-2D-dataset by drawling lines around clusters
% 
function ManualCluster(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% unpack
R = self.R{self.channel_to_work_with};
V_snippets = self.getSnippets(self.channel_to_work_with);


channel = self.channel_to_work_with;
% if it's intracellular
temp = isstrprop(self.common.data_channel_names{channel},'upper');
if any(temp)

	% intracellular 
	default_neuron_name = self.common.data_channel_names{channel};
else
	default_neuron_name =  self.nerve2neuron.(self.common.data_channel_names{channel});
end

if iscell(default_neuron_name)
	default_names = [default_neuron_name, 'Noise'];
else
	default_names = {default_neuron_name, 'Noise'};
end


% save this info for automation 
if ~self.automatic
	[idx, labels] = manualCluster(R,V_snippets,default_names,@self.showSpikeInContext);

	if self.watch_me
		% need to save this for automation later on 

		self.common.automate_info(self.channel_to_work_with).operation(end).data.x = R(1,:);
		if size(R,1) > 1
			self.common.automate_info(self.channel_to_work_with).operation(end).data.y = R(2,:);
		else
			self.common.automate_info(self.channel_to_work_with).operation(end).data.y = [];
		end
		self.common.automate_info(self.channel_to_work_with).operation(end).data.idx = idx;
	end

else
	data = self.common.automate_info(self.channel_to_work_with).operation(self.current_operation).data;

	% check if we're working in 1D or 2D
	if isempty(data.y)
		% 1D

		x = data.x; 
		X = R(1,:); 

		% find the gravitational "pull" on every point from
		% the reference data set
		W = 0*unique(data.idx);
		unique_idx = unique(data.idx);
		idx = 0*X;
		for i = 1:length(X)
			d = 1./((X(i) - x).^2);
			W = 0*W;
			for j = 1:length(W)
				W(j) = sum(d(data.idx == unique_idx(j)));
			end
			[~,idx(i)] = max(W);
			idx(i) = unique_idx(idx(i));
		end
		labels = default_names;
		if self.verbosity > 5
			figure('outerposition',[300 300 1200 999],'PaperUnits','points','PaperSize',[1200 999]); hold on
			ax(1) = subplot(2,1,1); hold on
			ax(2) = subplot(2,1,2); hold on
			c = lines;
			for i = 1:max(data.idx)
				temp = data.x(data.idx == i);
				plot(ax(1),temp,randn(length(temp),1),'o','Color',c(i,:));
				temp = X(idx == i);
				plot(ax(2),temp,randn(length(temp),1),'s','Color',c(i,:))
			end
			equalizeAxes

		end
	else
		% 2D
		x = data.x; y = data.y;
		X = R(1,:); Y = R(2,:);


		% find the gravitational "pull" on every point from
		% the reference data set
		W = 0*unique(data.idx);
		unique_idx = unique(data.idx);
		idx = 0*X;
		for i = 1:length(X)
			d = 1./((X(i) - x).^2 + (Y(i) - y).^2);
			W = 0*W;
			for j = 1:length(W)
				W(j) = sum(d(data.idx == unique_idx(j)));
			end
			[~,idx(i)] = max(W);
			idx(i) = unique_idx(idx(i));
		end
		labels = default_names;
	end

end

putative_spikes = find(self.putative_spikes(:,channel));
this_nerve = self.common.data_channel_names{channel};


for i = 1:length(labels)
	if strcmp(labels{i},'Noise')
		continue
	end

	these_spikes = putative_spikes(idx==i);

	self.spikes.(this_nerve).(labels{i}) = these_spikes;

end

% update the X and Y data since we don't want to show everything
a = find(self.time >= 0, 1, 'first');
z = find(self.time <= 5, 1, 'last');

for i = 1:length(self.handles.ax.data)
	try
	    self.handles.ax.ax(i).XLim = [0 5];
	    self.handles.ax.data(i).XData = self.time(a:z);
	    self.handles.ax.data(i).YData = self.raw_data(a:z,i);
	catch
	end
end
