% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%

function redrawIgnoredSections(self)

if isempty(self.handles)
	return
end

% update the X and Y data since we don't want to show everything
xlim = self.handles.ax(1).XLim;
a = find(self.time >= xlim(1), 1, 'first');
z = find(self.time <= xlim(2), 1, 'last');

ignore_section = full(self.ignore_section);

for i = 1:length(self.handles.ignored_data)
	y = NaN*self.handles.data(i).YData;
	y((ignore_section(a:z)) == 1) = self.handles.data(i).YData(ignore_section(a:z) == 1);
	self.handles.ignored_data(i).YData = y;
end
