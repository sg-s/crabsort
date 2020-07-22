%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% callback when main window is closed

function close(self,~,~)


path_name = self.path_name;
pref = self.pref;

if self.verbosity > 9
	disp(mfilename)
end


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

% consolidate data
if isempty(path_name)
	return
end


try
	p = strsplit(path_name,filesep);
	if isempty(p{end})
		p = p{end-1};
	else
		p = p{end};
	end


	
	crabsort.consolidate(p,'neurons',pref.consolidate_these_neurons_on_close)
catch
end