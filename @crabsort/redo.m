function redo(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

s.A = [];
s.B = [];
s.N = [];
s.use_this_fragment = [];

s.plotResp;

s.saveData;

% re-enable some things
s.handles.method_control.Enable = 'on';