%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% Srinivas Gorur-Shandilya

function [] = resetZoom(self,~,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


% update the X and Y data since we don't want to show everything
a = find(self.time >= 0, 1, 'first');
z = find(self.time <= 5, 1, 'last');

for i = 1:length(self.handles.ax.data)
    self.handles.ax.ax(i).XLim = [0 5];
    self.handles.ax.data(i).XData = self.time(a:z);
    self.handles.ax.data(i).YData = self.raw_data(a:z,i);
end