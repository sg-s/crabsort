%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% destroys all axes, and makes new ones
% based on n_channels

function redrawAxes(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

figure(self.handles.main_fig)

% are there already some axes handles? 
if isfield(self.handles,'ax') && ~isempty(self.handles.ax)

	% there exist some axes already
	if length(self.handles.ax.ax) == self.n_channels
		% no need to redraw axes
	else
		% need to destroy all axes and start from scratch
		self.destroyAllAxes;
	end
else
	% no axes handles at all.
	self.createNewAxes;
end

% this gets run no matter what
self.showHideAxes;

return

self.updateAxesLabels;
self.updateAxesPlots;


return



c = lines;
z = find(self.time > 5,1,'first');

if isempty(z)
	z = length(self.time);
end


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



uistack(self.handles.popup,'top')