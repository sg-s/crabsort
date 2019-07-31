%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% destroys all axes, and makes new ones
% based on n_channels

function redrawAxes(self)

if ~isempty(self.handles)
    if isfield(self.handles,'main_fig')
        set(self.handles.main_fig, 'pointer', 'watch')
        drawnow
    end
end


% are there already some axes handles? 
if isfield(self.handles,'ax') && ~isempty(self.handles.ax) && isfield(self.handles.ax,'ax')

	% there exist some axes already
	if length(self.handles.ax.ax) == self.n_channels
		% no need to redraw axes
	else
		% need to destroy all axes and start from scratch
		self.destroyAllAxes;
		self.createNewAxes;
	end
else
	% no axes handles at all.
	self.createNewAxes;
end

% this gets run no matter what
self.showHideAxes;


if ~isempty(self.handles)
    if isfield(self.handles,'main_fig')
        set(self.handles.main_fig, 'pointer', 'arrow')
        drawnow
    end
end