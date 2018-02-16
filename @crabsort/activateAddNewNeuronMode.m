function activateAddNewNeuronMode(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

self.handles.mode_new_spike.Value = 1;