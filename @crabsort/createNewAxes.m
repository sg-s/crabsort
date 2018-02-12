function createNewAxes(self)


% figure out how many channels to acutally plot
% this differes from self.n_channels because
% some channels can be hidden
n_channels_to_plot = sum(strcmp(self.common.show_hide_channels,'on'));
M = {'o','x','d','p','h','+','s'};
z = find(self.time > 5,1,'first');
c = lines;

bottom_plot = .05;
top_plot = .9;
spacing = (top_plot - bottom_plot)/n_channels_to_plot;
plot_idx = 0;

for i = 1:self.n_channels

	if strcmp(self.common.show_hide_channels{i},'off')
		continue
	end

	plot_idx = plot_idx + 1;

	self.handles.ax(i) = subplot(n_channels_to_plot,1,plot_idx); hold on

	if plot_idx > 1 && plot_idx < self.n_channels
		self.handles.ax(i).XColor = 'w';
		self.handles.ax(i).XTick = [];
	end

	if i == n_channels_to_plot && i > 1
		self.handles.ax(i).XAxisLocation = 'top';
	end

	% show only 5 seconds at a time
	self.handles.ax(i).XLim = [0 5];


	self.handles.data(i) = plot(self.time(1:z),self.raw_data(1:z,i),'Color',c(i,:),'LineWidth',self.pref.plot_line_width);


	% make plots for found spikes (putative spikes)
	self.handles.found_spikes(i) = plot(NaN,NaN,'o','LineStyle','none','Color',[1 0 0]);

	% support up to 10 units on each 
	% this weird syntax is so that the primary unit on each 
	% nerve is labeled with the same color as the color
	% that is used for the channel 
	self.handles.sorted_spikes(i).unit(1) = plot(NaN,NaN,M{1},'LineStyle','none','Color',c(i,:));
	for j = 2:length(M)
		self.handles.sorted_spikes(i).unit(j) = plot(NaN,NaN,M{j},'LineStyle','none','Color',c(j,:));
	end


	% ignore negative Yticks
	self.handles.ax(i).YTick = self.handles.ax(i).YTick(self.handles.ax(i).YTick >= 0);


	% % for every axes, make a red line that is used to indicate 
	% % a spike -- this will be used by callbacks from 
	% % clustering algorithms (and anything else, really)
	self.handles.spike_marker(i) = plot(self.handles.ax(i),NaN,NaN,'r');


end

self.handles.popup.Visible = 'off';

plot_idx = 0;

% configure zoom 
self.handles.zoom_handles = zoom(self.handles.main_fig);
self.handles.zoom_handles.Motion = 'horizontal';
self.handles.zoom_handles.ActionPostCallback = @self.zoomCallback;

for i = 1:self.n_channels
	if strcmp(self.common.show_hide_channels{i},'off')
		continue
	end
	plot_idx = plot_idx + 1;


	% make things a little more flush
	self.handles.ax(i).Position(1) = .1;
	self.handles.ax(i).Position(2) = bottom_plot + spacing*(plot_idx-1);
	self.handles.ax(i).Position(3) = .89;
	self.handles.ax(i).Position(4) = .95*spacing;


	y = (self.handles.ax(i).Position(4))/2 + self.handles.ax(i).Position(2);

	self.handles.channel_names(i) = uicontrol(self.handles.main_fig,'units','normalized','Position',[.01 y .06 .02],'Style', 'text', 'String', self.builtin_channel_names{i},'BackgroundColor',[1 1 1],'FontSize',self.pref.fs);


	% make the channel labels 
	if ~isempty(self.common.data_channel_names) && ~isempty(self.common.data_channel_names{i})
		V = find(strcmp(self.channel_names,self.common.data_channel_names{i}));
	else
		V = 1;
	end
	self.handles.channel_label_chooser(i) = uicontrol(self.handles.main_fig,'units','normalized','Position',[.01 y-.06 .05 .06],'Style', 'popupmenu', 'String', self.channel_names,'callback',@self.updateChannel,'FontSize',self.pref.fs,'Value',V);

	self.handles.recording(i) = uicontrol(self.handles.main_fig,'units','normalized','Position',[.01 y+.02 .03 .02],'Style', 'text', 'String', 'REC','BackgroundColor',[1 0 0],'ForegroundColor',[1 1 1],'FontSize',self.pref.fs,'FontWeight','bold','Visible','off');

	% show indicator of automate status
	self.handles.has_automate(i) = uicontrol(self.handles.main_fig,'units','normalized','Position',[.05 y+.02 .01 .02],'Style', 'text', 'String', 'A','BackgroundColor',[0 0.5 0],'ForegroundColor',[1 1 1],'FontSize',self.pref.fs,'FontWeight','bold','Visible','off');


end





% make a slider to futz with the YLims for each channel 
self.handles.ylim_slider = uicontrol(self.handles.main_fig,'units','normalized','Position',[.06 bottom_plot .02 spacing*n_channels_to_plot],'Style', 'slider', 'Max',1,'Min',0,'Callback',@self.resetYLims,'Value',.1);

try    % R2013b and older
   addlistener(self.handles.ylim_slider,'ActionEvent',@self.resetYLims);
catch  % R2014a and newer
   addlistener(self.handles.ylim_slider,'ContinuousValueChange',@self.resetYLims);
end
drawnow