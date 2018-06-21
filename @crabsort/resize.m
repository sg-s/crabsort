%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% callback when main window is resized

function resize(self,~,~)


if ~isfield(self.handles,'main_fig')
	return
end

if ~isfield(self.handles,'ax')
	return
end


fig_width = self.handles.main_fig.Position(3);
fig_height = self.handles.main_fig.Position(4);

% channel label chooser
default_width = .05;
min_px = 90; 


for i = 1:length(self.handles.ax.channel_label_chooser)
	temp = self.handles.ax.channel_label_chooser(i);
	if temp.Position(3)*fig_width < 1.05*min_px
		temp.Position(3) = min_px/fig_width;
	else
		temp.Position(3) = default_width;
	end
end
drawnow nocallbacks;


% ylim_slider
default_pos = .06;
min_px = 95;
if self.handles.ylim_slider.Position(1)*fig_width < 1.05*min_px
	self.handles.ylim_slider.Position(1) = min_px/fig_width;
else
	self.handles.ylim_slider.Position(1) = default_pos;
end
drawnow nocallbacks;

% axes
default_pos = .1;
buffer_px = 50;
min_pos = self.handles.ylim_slider.Position(1) + self.handles.ylim_slider.Position(3) + buffer_px/fig_width;

for i = 1:length(self.handles.ax.ax)
	temp = self.handles.ax.ax(i);

	if temp.Position(1) < 1.05*min_pos
		temp.Position(1) = min_pos;
	else
		temp.Position(1) = default_pos;
	end
	temp.Position(3) = 1 - temp.Position(1)-.01;
end
drawnow nocallbacks;

self.handles.scroll_bar.Position(1) = temp.Position(1);
self.handles.scroll_bar.Position(3) = temp.Position(3);
drawnow nocallbacks;

% now we do the vertical stuff
default_pos = .92;
default_height = .07;
min_px = 100;


if self.handles.spike_detection_panel.Position(4)*fig_height < 1.05*min_px

	self.handles.spike_detection_panel.Position(4) = min_px/fig_height;
	self.handles.spike_detection_panel.Position(2) = .99 - self.handles.spike_detection_panel.Position(4);

	self.handles.data_panel.Position(4) = min_px/fig_height;
	self.handles.data_panel.Position(2) = .99 - self.handles.data_panel.Position(4);

	self.handles.dim_red_panel.Position(4) = min_px/fig_height;
	self.handles.dim_red_panel.Position(2) = .99 - self.handles.dim_red_panel.Position(4);

	self.handles.cluster_panel.Position(4) = min_px/fig_height;
	self.handles.cluster_panel.Position(2) = .99 - self.handles.cluster_panel.Position(4);

	self.handles.manual_panel.Position(4) = min_px/fig_height;
	self.handles.manual_panel.Position(2) = .99 - self.handles.manual_panel.Position(4);

else
	self.handles.spike_detection_panel.Position(4) = default_height;
	self.handles.spike_detection_panel.Position(2) = default_pos;

	self.handles.data_panel.Position(4) = default_height;
	self.handles.data_panel.Position(2) = default_pos;

	self.handles.dim_red_panel.Position(4) = default_height;
	self.handles.dim_red_panel.Position(2) = default_pos;

	self.handles.cluster_panel.Position(4) = default_height;
	self.handles.cluster_panel.Position(2) = default_pos;

	self.handles.manual_panel.Position(4) = default_height;
	self.handles.manual_panel.Position(2) = default_pos;


end

self.showHideAxes(.05,self.handles.dim_red_panel.Position(2))

self.handles.ylim_slider.Position(4) = self.handles.dim_red_panel.Position(2) - .05;