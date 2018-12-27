%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% creates self.n_channels new axes, assuming that
% the GUI has no already-existing axes or 
% associated uicontrol elements 

function createNewAxes(self)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


% defensive programming 
assert(~isfield(self.handles,'ax'),'Axes already exist?')


% we're going to blindly create self.n_channel
% plots, and let other functions worry about 
% hiding/showing specific channels 
z = find(self.time > 5,1,'first');
c = lines;

bottom_plot = .05;
top_plot = .9;
spacing = (top_plot - bottom_plot)/self.n_channels;

M = self.pref.spike_markers;

for i = self.n_channels:-1:1

	self.handles.ax.ax(i) = subplot(self.n_channels,1,self.n_channels - i + 1); hold on

	if i > 1 && i < self.n_channels
		self.handles.ax.ax(i).XColor = 'w';
		self.handles.ax.ax(i).XTick = [];
	end

	if i == self.n_channels && i > 1
		self.handles.ax.ax(i).XAxisLocation = 'top';
	end

	% show only 5 seconds at a time
	self.handles.ax.ax(i).XLim = [0 5];


	self.handles.ax.data(i) = plot(self.time(1:z),self.raw_data(1:z,i),'Color',c(i,:),'LineWidth',self.pref.plot_line_width);


	% make plots for found spikes (putative spikes)
	self.handles.ax.found_spikes(i) = plot(NaN,NaN,'o','LineStyle','none','Color',self.pref.putative_spike_colour);

	% support up to 10 units on each 
	% this weird syntax is so that the primary unit on each 
	% nerve is labeled with the same color as the color
	% that is used for the channel 
	self.handles.ax.sorted_spikes(i).unit(1) = plot(NaN,NaN,M{1},'LineStyle','none','Color',c(i,:));
	for j = 2:length(M)
		self.handles.ax.sorted_spikes(i).unit(j) = plot(NaN,NaN,M{j},'LineStyle','none','Color',c(j,:));
	end


	% ignore negative Yticks
	self.handles.ax.ax(i).YTick = self.handles.ax.ax(i).YTick(self.handles.ax.ax(i).YTick >= 0);


	% % for every axes, make a red line that is used to indicate 
	% % a spike -- this will be used by callbacks from 
	% % clustering algorithms (and anything else, really)
	self.handles.ax.spike_marker(i) = plot(self.handles.ax.ax(i),NaN,NaN,'r');


end

% I don't know why this is split into two for loops
% All I know is that works when it is split, and fails
% without error when it's not. I don't want to worry about
% it. It works. Don't touch it.


% make ui panels
c = lines(100);
for i = 1:self.n_channels
	self.handles.ax.panel(i) = uipanel('Parent',self.handles.main_fig,'BackgroundColor',[1 1 1],'Title',self.builtin_channel_names{i},'ForegroundColor',c(i,:),'FontWeight','bold');
	self.handles.ax.panel(i).Position = [.01 bottom_plot + spacing*(i-1) .1 .95*spacing];
end

for i = 1:self.n_channels

	% make things a little more flush
	self.handles.ax.ax(i).Position(1) = .13;
	self.handles.ax.ax(i).Position(2) = bottom_plot + spacing*(i-1);
	self.handles.ax.ax(i).Position(3) = .84;
	self.handles.ax.ax(i).Position(4) = .95*spacing;


	y = (self.handles.ax.ax(i).Position(4))/2 + self.handles.ax.ax(i).Position(2);


	% make the channel labels 
	if ~isempty(self.common.data_channel_names) && ~isempty(self.common.data_channel_names{i})
		V = find(strcmp(self.channel_names,self.common.data_channel_names{i}));
	else
		V = 1;
	end
	self.handles.ax.channel_label_chooser(i) = uicontrol(self.handles.ax.panel(i),'units','normalized','Position',[.01 .9 .9 .1],'Style', 'popupmenu', 'String', self.channel_names,'callback',@self.updateChannel,'FontSize',self.pref.fs,'Value',V);

	% disable the channel_label_chooser if need be
	if isfield(self.common,'channel_name_lock')
		if self.common.channel_name_lock(i) == 1
			self.handles.ax.channel_label_chooser(i).Enable = 'off';
		end
	end

	% make an indicator of recording status
	self.handles.ax.recording(i) = uicontrol(self.handles.ax.panel(i),'units','normalized','Position',[.01 .05 .3 .15],'Style', 'text', 'String', 'REC','BackgroundColor',[.9 .9 .9],'ForegroundColor',[1 1 1],'FontSize',self.pref.fs,'FontWeight','bold','Visible','on','ButtonDownFcn',@self.updateWatchMe,'Enable','Inactive');

	% show indicator of automate status
	self.handles.ax.has_automate(i) = uicontrol(self.handles.ax.panel(i),'units','normalized','Position',[.41 .05 .1 .15],'Style', 'text', 'String', 'A','BackgroundColor',[.9 .9 .9],'ForegroundColor',[1 1 1],'FontSize',self.pref.fs,'FontWeight','bold','Visible','on');

	% make indicators for neural network status 
	self.handles.ax.NN_accuracy(i) = uicontrol(self.handles.ax.panel(i),'units','normalized','Position',[.01 .21 .4 .2],'Style', 'text', 'String', '00.0%','BackgroundColor',[1 1 1],'ForegroundColor',[.7 .7 .7],'FontSize',self.pref.fs*2,'FontWeight','bold','Visible','on');
	self.handles.ax.NN_status(i) = uicontrol(self.handles.ax.panel(i),'units','normalized','Position',[.01 .41 .8 .2],'Style', 'text', 'String', 'No data','BackgroundColor',[1 1 1],'ForegroundColor',[.7 .7 .7],'FontSize',self.pref.fs*2,'FontWeight','bold','Visible','on','HorizontalAlignment','left');



end

% now make some global things that aren't channel dependent

% make a slider to futz with the YLims for each channel 
self.handles.ylim_slider = uicontrol(self.handles.main_fig,'units','normalized','Position',[.1 bottom_plot .02 spacing*self.n_channels],'Style', 'slider', 'Max',1,'Min',0,'Callback',@self.resetYLims,'Value',.1);

try    % R2013b and older
   addlistener(self.handles.ylim_slider,'ActionEvent',@self.resetYLims);
catch err % R2014a and newer
   addlistener(self.handles.ylim_slider,'ContinuousValueChange',@self.resetYLims);
end

self.handles.popup.Visible = 'off';

% configure zoom 
self.handles.zoom_handles = zoom(self.handles.main_fig);
self.handles.zoom_handles.Motion = 'horizontal';
self.handles.zoom_handles.ActionPostCallback = @self.zoomCallback;
self.handles.scroll_bar.Visible = 'on';
drawnow

