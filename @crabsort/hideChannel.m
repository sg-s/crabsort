function hideChannel(self, src, ~)

channel = find(self.handles.ax.hide_channel_button == src);

self.showHideChannels(self.handles.menu_name(6).Children(self.n_channels - channel + 1));