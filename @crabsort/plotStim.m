% plots the stimulus in the secondary plot

function [] = plotStim(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if min(s.stimulus) > 0
	y1 = min(s.stimulus)/2;
else
	y1 = min(s.stimulus)*2;
end
if max(s.stimulus) > 0
	y2 = max(s.stimulus)*2;
else
	y2 = max(s.stimulus)/2;
end

set(s.handles.ax2_data,'XData',s.time,'YData',s.stimulus,'Color','k')
if y2 > y1
	set(s.handles.ax2,'YLim',[y1 y2]);
end