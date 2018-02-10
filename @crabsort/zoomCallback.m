%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% zoom callback

function zoomCallback(self,src,event)

idx = find(self.handles.ax == event.Axes);

% change the XLim of all the other axes to match this
for i = 1:length(self.handles.ax)
	if i == idx
		continue
	end

	try
		self.handles.ax(i).XLim = self.handles.ax(idx).XLim;
	catch
	end

end 
