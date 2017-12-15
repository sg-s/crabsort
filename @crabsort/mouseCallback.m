
function mouseCallback(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end
	
% p = get(s.handles.ax1,'CurrentPoint');
% p = p(1,1:2);
% modify(s,p)
