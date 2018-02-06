% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
function ignoreSection(self,src,~)


% get the Xlimits
xlim = floor(self.handles.ax(1).XLim/self.dt);

if isempty(self.ignore_section)
	self.ignore_section = sparse(length(self.time),1);
end

if strcmp(src.Text,'Ignore section')
	self.ignore_section(xlim(1):xlim(2)) = 1;
elseif strcmp(src.Text,'UNignore section')
	self.ignore_section(xlim(1):xlim(2)) = 0;
else
	error('[#331] Unknown caller ')
end


self.redrawIgnoredSections;
