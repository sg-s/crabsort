%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% callback when main window is closed

function close(self,~,~)



try
	cancel(self.workers);
catch
end
try
	delete(self.workers);
catch
end

try
	stop(self.timer_handle)
catch
end

try
	delete(self.timer_handle)
catch
end



self.saveData;

try	
	delete(self.handles.puppeteer_handle)
catch
end

delete(self.handles.main_fig)
delete(self)

