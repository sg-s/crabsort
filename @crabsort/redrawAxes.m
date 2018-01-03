%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% destroys all axes, and makes new ones
% based on n_channels

function redrawAxes(self)

% first destroy old axes
if isfield(self.handles,'ax')
	for i = 1:length(self.handles.ax)
		delete(self.handles.ax(i));
	end
	self.handles = rmfield(self.handles,'ax');
end

% destroy the channel pickers
if isfield(self.handles,'channel_label_chooser')
	for i = 1:length(self.handles.channel_label_chooser)
		delete(self.handles.channel_label_chooser(i));
	end
	self.handles = rmfield(self.handles,'channel_label_chooser');
end

% also destroy the labels for the built in channel names
if isfield(self.handles,'channel_names')
	for i = 1:length(self.handles.channel_names)
		delete(self.handles.channel_names(i));
	end
	self.handles = rmfield(self.handles,'channel_names');
end


c = lines;
z = find(self.time > 5,1,'first');
for i = 1:self.n_channels
	self.handles.ax(i) = subplot(self.n_channels,1,i); hold on

	self.handles.zoom_handles(i) = zoom(self.handles.ax(i));
	self.handles.zoom_handles(i).Motion = 'horizontal';
	self.handles.zoom_handles(i).ActionPostCallback = @self.zoomCallback;


	% % show only 5 seconds at a time
	self.handles.ax(i).XLim = [0 5];

	self.handles.data(i) = plot(self.time(1:z),self.raw_data(1:z,i),'Color',c(i,:),'LineWidth',1);

	% futz with the YLims to make sure huge outliers don't swamp the trace


	% make plots for found spikes
	self.handles.found_spikes(i) = plot(NaN,NaN,'o','LineStyle','none','Color',[1 0 0]);

	self.handles.sorted_spikes(i).unit(1) = plot(NaN,NaN,'o','LineStyle','none','Color',c(i,:));
end


bottom_plot = .05;
top_plot = .9;
spacing = (top_plot - bottom_plot)/self.n_channels;

% make things a little more flush
for i = 1:self.n_channels
	self.handles.ax(i).Position(1) = .1;
	self.handles.ax(i).Position(2) = bottom_plot + spacing*(i-1);
	self.handles.ax(i).Position(3) = .89;
	self.handles.ax(i).Position(4) = .95*spacing;

	if i > 1
		self.handles.ax(i).XTickLabel = {};
	end

	% ignore negative Yticks
	self.handles.ax(i).YTick = self.handles.ax(i).YTick(self.handles.ax(i).YTick>=0);

	
end

% make the channel labels 
for i = 1:self.n_channels
	y = bottom_plot + spacing*(i-1);
	self.handles.channel_label_chooser(i) = uicontrol(self.handles.main_fig,'units','normalized','Position',[.01 y .06 .05],'Style', 'popupmenu', 'String', self.channel_names,'callback',@self.updateChannel);
end

for i = 1:self.n_channels
	y = bottom_plot + spacing*(i-1) + .05;
	self.handles.channel_names(i) = uicontrol(self.handles.main_fig,'units','normalized','Position',[.01 y .06 .02],'Style', 'text', 'String', self.metadata.recChNames{i},'BackgroundColor',[1 1 1]);
end

% make a slider to futz with the YLims for each channel 


self.handles.ylim_slider = uicontrol(self.handles.main_fig,'units','normalized','Position',[.06 self.handles.ax(1).Position(2) .02 self.handles.ax(end).Position(2)],'Style', 'slider', 'Max',1,'Min',0,'Callback',@self.resetYLims,'Value',.1);

try    % R2013b and older
   addlistener(self.handles.ylim_slider,'ActionEvent',@self.resetYLims);
catch  % R2014a and newer
   addlistener(self.handles.ylim_slider,'ContinuousValueChange',@self.resetYLims);
end


self.handles.scroll_bar.Visible = 'on';


% for every axes, make a red line that is used to indicate 
% a spike -- this will be used by callbacks from 
% clustering algorithms (and anything else, really)

for i = 1:self.n_channels
	self.handles.spike_marker(i) = plot(self.handles.ax(i),NaN,NaN,'r');
end