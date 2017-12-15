% callback when main window is closed

function close(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end


delete(s.handles.main_fig)
delete(s)
