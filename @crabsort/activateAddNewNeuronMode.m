function activateAddNewNeuronMode(self,~,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


self.handles.mode_new_spike.Value = 1;