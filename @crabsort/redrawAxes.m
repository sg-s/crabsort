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
for i = 1:self.n_channels
	self.handles.ax(i) = subplot(self.n_channels,1,i); hold on
	self.handles.data(i) = plot(self.time,self.raw_data(:,i),'Color',c(i,:));
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

	% show only 5 seconds at a time
	self.handles.ax(i).XLim = [0 10];
end

% make the channel labels 

for i = 1:self.n_channels
	y = bottom_plot + spacing*(i-1);
	self.handles.channel_label_chooser(i) = uicontrol(self.handles.main_fig,'units','normalized','Position',[.01 y .07 .05],'Style', 'popupmenu', 'String', self.channel_names,'callback',@self.updateChannel);
end

for i = 1:self.n_channels
	y = bottom_plot + spacing*(i-1) + .05;
	self.handles.channel_names(i) = uicontrol(self.handles.main_fig,'units','normalized','Position',[.01 y .07 .02],'Style', 'text', 'String', self.metadata.recChNames{i});
end


self.handles.scroll_bar.Visible = 'on';