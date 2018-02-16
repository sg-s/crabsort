%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% shows or hides axes based on self.common.show_hide_channels

function showHideAxes(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

n_channels_to_show = sum(self.common.show_hide_channels);

bottom_plot = .05;
top_plot = .9;
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



		% do the same for the associated controls
		y = (self.handles.ax.ax(i).Position(4))/2 + self.handles.ax.ax(i).Position(2);

		self.handles.ax.channel_label_chooser(i).Position(2) = y - .06;
		self.handles.ax.recording(i).Position(2) = y + .02;
		self.handles.ax.has_automate(i).Position(2) = y + .02;
		self.handles.ax.channel_names(i).Position(2) = y;

		% show the plot and associated controls
		% except the recording and has_automate controls,
		% which we treat specially 
		for j = 1:length(fn)
			if strcmp(fn{j},'recording') 
				if ~isempty(self.channel_to_work_with)
					if self.watch_me && self.channel_to_work_with == i
						self.handles.ax.(fn{j})(i).Visible = 'on';
					else
						self.handles.ax.(fn{j})(i).Visible = 'off';
					end
				else
					self.handles.ax.(fn{j})(i).Visible = 'off';
				end
			elseif strcmp(fn{j},'has_automate')
				if self.doesChannelHaveAutomateInfo(i)
					self.handles.ax.(fn{j})(i).Visible = 'on';
				else
					self.handles.ax.(fn{j})(i).Visible = 'off';
				end
			else
				self.handles.ax.(fn{j})(i).Visible = 'on';
			end
		end

		% show all children of plot
		ax = self.handles.ax.ax(i);
		for j = 1:length(ax.Children)
			ax.Children(j).Visible = 'on';
		end

	else
		% hide the plot and associated controls
		for j = 1:length(fn)
			self.handles.ax.(fn{j})(i).Visible = 'off';
		end

		% hide all children of the plot
		ax = self.handles.ax.ax(i);
		for j = 1:length(ax.Children)
			ax.Children(j).Visible = 'off';
		end

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
