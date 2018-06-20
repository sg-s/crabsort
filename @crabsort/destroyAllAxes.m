%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% destroys all axes and associated
% UI control elements in self.handles.ax


function destroyAllAxes(self)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


% destroy it all
fn1 = fieldnames(self.handles.ax);


for i = 1:length(fn1)
	if strcmp(fn1{i},'sorted_spikes')
		% since we're deleting the axes that contains this
		% let's hope they are also deleted 

	else
		for j = 1:length(self.handles.ax.(fn1{i}))
			delete(self.handles.ax.(fn1{i})(j))
		end
	end


end

self.handles.ax = [];
self.handles = rmfield(self.handles,'ax');
