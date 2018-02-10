%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% destroys all axes, and makes new ones
% based on n_channels

function redrawAxes(self, force)

figure(self.handles.main_fig)

c = lines;
z = find(self.time > 5,1,'first');

if isempty(z)
	z = length(self.time);
end

M = {'o','x','d','p','h','+','s'};

if isfield(self.handles,'ax') && length(self.handles.ax) == self.n_channels && force == false
	% no need to redraw axes

	% remove all the automate info
	for i = 1:self.n_channels
		if strcmp(self.common.show_hide_channels{i},'on')
			self.handles.has_automate(i).Visible = 'off';
		
			self.handles.ax(i).XLim = [0 5];
			self.handles.data(i).XData = self.time(1:z);
			self.handles.data(i).YData = self.raw_data(1:z,i);
			self.handles.found_spikes(i).XData = NaN;
			self.handles.found_spikes(i).YData = NaN;
			for j = 1:length(M)
				self.handles.sorted_spikes(i).unit(j).XData = NaN;
				self.handles.sorted_spikes(i).unit(j).YData = NaN;
			end
		end
	end

else
	self.destroyAllAxes;
	self.createNewAxes;
	
end


self.handles.scroll_bar.Visible = 'on';

for i = 1:self.n_channels
	% if a channel has automate info, mark it as such
	try
		operation = self.common.automate_info(i).operation;
		if length(operation) > 2
			self.handles.has_automate(i).Visible = 'on';
		end
	catch
	end

end

uistack(self.handles.popup,'top')