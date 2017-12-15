function [] = resetZoom(s,~,~)

set(s.handles.ax1,'XLim',[min(s.time) max(s.time)])