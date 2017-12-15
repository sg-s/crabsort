% callback when main window is closed

function close(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end


self.saveData;


delete(self.handles.main_fig)
delete(self)
