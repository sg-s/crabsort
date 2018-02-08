%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% destroys all axes, and makes new ones
% based on n_channels

function redrawAxes(self)

figure(self.handles.main_fig)

c = lines;
z = find(self.time > 5,1,'first');

if isempty(z)
	z = length(self.time);
end



if isfield(self.handles,'ax') && length(self.handles.ax) == self.n_channels
	% no need to redraw axes
	no_destroy = true;
else
	no_destroy = false;
	% destroy it all
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

end


M = {'o','x','d','p','h','+','s'};
for i = 1:self.n_channels
	if no_destroy
		self.handles.ax(i).XLim = [0 5];
		self.handles.data(i).XData = self.time(1:z);
		self.handles.data(i).YData = self.raw_data(1:z,i);
		self.handles.found_spikes(i).XData = NaN;
		self.handles.found_spikes(i).YData = NaN;
		for j = 1:length(M)
			self.handles.sorted_spikes(i).unit(j).XData = NaN;
			self.handles.sorted_spikes(i).unit(j).YData = NaN;
		end
	else
		self.handles.ax(i) = subplot(self.n_channels,1,i); hold on


		if i > 1 && i < self.n_channels
			self.handles.ax(i).XColor = 'w';
			self.handles.ax(i).XTick = [];
		end

		if i == self.n_channels && i > 1
			self.handles.ax(i).XAxisLocation = 'top';
		end

		self.handles.zoom_handles(i) = zoom(self.handles.ax(i));
		self.handles.zoom_handles(i).Motion = 'horizontal';
		self.handles.zoom_handles(i).ActionPostCallback = @self.zoomCallback;

		% % show only 5 seconds at a time
		self.handles.ax(i).XLim = [0 5];


		self.handles.data(i) = plot(self.time(1:z),self.raw_data(1:z,i),'Color',c(i,:),'LineWidth',self.pref.plot_line_width);


		% make plots for found spikes
		self.handles.found_spikes(i) = plot(NaN,NaN,'o','LineStyle','none','Color',[1 0 0]);

		% support up to 10 units on each 
		self.handles.sorted_spikes(i).unit(1) = plot(NaN,NaN,M{1},'LineStyle','none','Color',c(i,:));
		for j = 2:length(M)
			self.handles.sorted_spikes(i).unit(j) = plot(NaN,NaN,M{j},'LineStyle','none','Color',c(j,:));
		end
	end
end


bottom_plot = .05;
top_plot = .9;
spacing = (top_plot - bottom_plot)/self.n_channels;

if ~no_destroy
	% make things a little more flush
	for i = 1:self.n_channels
		self.handles.ax(i).Position(1) = .1;
		self.handles.ax(i).Position(2) = bottom_plot + spacing*(i-1);
		self.handles.ax(i).Position(3) = .89;
		self.handles.ax(i).Position(4) = .95*spacing;

		% ignore negative Yticks
		self.handles.ax(i).YTick = self.handles.ax(i).YTick(self.handles.ax(i).YTick>=0);

	end
end

% make the channel labels 
for i = 1:self.n_channels
	y = bottom_plot + spacing*(i-1);
	self.handles.channel_label_chooser(i) = uicontrol(self.handles.main_fig,'units','normalized','Position',[.01 y-.01 .05 .06],'Style', 'popupmenu', 'String', self.channel_names,'callback',@self.updateChannel,'FontSize',self.pref.fs);
end

for i = 1:self.n_channels
	y = bottom_plot + spacing*(i-1) + .05;
	self.handles.channel_names(i) = uicontrol(self.handles.main_fig,'units','normalized','Position',[.01 y .06 .02],'Style', 'text', 'String', self.builtin_channel_names{i},'BackgroundColor',[1 1 1]);
end

% make a slider to futz with the YLims for each channel 

if ~no_destroy
	self.handles.ylim_slider = uicontrol(self.handles.main_fig,'units','normalized','Position',[.06 self.handles.ax(1).Position(2) .02 self.handles.ax(end).Position(2)],'Style', 'slider', 'Max',1,'Min',0,'Callback',@self.resetYLims,'Value',.1);

	try    % R2013b and older
	   addlistener(self.handles.ylim_slider,'ActionEvent',@self.resetYLims);
	catch  % R2014a and newer
	   addlistener(self.handles.ylim_slider,'ContinuousValueChange',@self.resetYLims);
	end
end


self.handles.scroll_bar.Visible = 'on';


% for every axes, make a red line that is used to indicate 
% a spike -- this will be used by callbacks from 
% clustering algorithms (and anything else, really)

for i = 1:self.n_channels
	self.handles.spike_marker(i) = plot(self.handles.ax(i),NaN,NaN,'r');
end

uistack(self.handles.popup,'top')