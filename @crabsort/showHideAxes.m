%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% shows or hides axes based on self.common.show_hide_channels

function showHideAxes(self, bottom_plot, top_plot)

d = dbstack;
if self.verbosity > 3
	if length(d)>1
		disp(['[' mfilename '] called by ' d(2).name])
	end
end


% stop timer
stop(self.timer_handle)

assert(isfield(self.handles,'ax'),'No axes found in self.handles. showHideAxes was called, but there is nothing to do because the there are no axes handles. it looks like createNewAxes needed to be called, but was not.')

n_channels_to_show = sum(self.common.show_hide_channels);


if nargin == 1
	bottom_plot = .05;
	top_plot = .9;
end
spacing = (top_plot - bottom_plot)/n_channels_to_show;

% plot_idx keeps track of how many plots 
% we actually show
plot_idx = 0;

fn = fieldnames(self.handles.ax);

for i = 1:self.n_channels

	self.handles.ax.ax(i).XColor = 'w';
	self.handles.ax.ax(i).XTick = [];
	self.handles.ax.ax(i).XAxisLocation = 'top';




	if self.common.show_hide_channels(i)
		% show the plot in the correct place

		plot_idx = plot_idx + 1;

		self.handles.ax.ax(i).Position(2) = bottom_plot + spacing*(plot_idx-1);
		self.handles.ax.ax(i).Position(4) = .95*spacing;



		% do the same for the associated panel
		y = (self.handles.ax.ax(i).Position(4))/2 + self.handles.ax.ax(i).Position(2);


		self.handles.ax.panel(i).Visible = 'on';
		self.handles.ax.panel(i).Position = [.01 bottom_plot + spacing*(plot_idx-1) .1 .95*spacing];
		


		% to do: show/hide automate and rec controls
		if self.doesChannelHaveAutomateInfo(i)
			self.handles.ax.has_automate(i).BackgroundColor = [0 .5 0];
		else
			self.handles.ax.has_automate(i).BackgroundColor = [.9 .9 .9];
		end

		% show all children of plot
		ax = self.handles.ax.ax(i);
		for j = 1:length(ax.Children)
			set(ax.Children(j),'Visible','on');
		end


	else
		% hide the plot 
		self.handles.ax.ax(i).Visible = 'off';

		% hide all children of the plot
		ax = self.handles.ax.ax(i);
		for j = 1:length(ax.Children)
			set(ax.Children(j),'Visible','off');
		end

		% hide the panel
		self.handles.ax.panel(i).Visible = 'off';
		

	end

end

% show the X-axis on the first and last plot

first_ax = find(strcmp({self.handles.ax.ax.Visible},'on'),1,'first');
last_ax = find(strcmp({self.handles.ax.ax.Visible},'on'),1,'last');


self.handles.ax.ax(first_ax).XColor = 'k';
self.handles.ax.ax(first_ax).XAxisLocation = 'bottom';
self.handles.ax.ax(first_ax).XTickMode = 'auto';

self.handles.ax.ax(last_ax).XColor = 'k';
self.handles.ax.ax(last_ax).XAxisLocation = 'top';
self.handles.ax.ax(last_ax).XTickMode = 'auto';


start(self.timer_handle)