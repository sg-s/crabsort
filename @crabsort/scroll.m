%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% moves plots when scroll wheel or scroll bar is moved

function scroll(self,src,event)

xlimits = get(self.handles.ax(1),'XLim');
xrange = (xlimits(2) - xlimits(1));

if self.handles.scroll_bar == src

    newlim(1) = max(self.time)*src.Value;
    newlim(2) = newlim(1) + xrange;

else


    scroll_amount = event.VerticalScrollCount;


    if scroll_amount < 0
        if xlimits(1) <= min(self.time)
            return
        else
            newlim(1) = max([min(self.time) (xlimits(1)-.2*xrange)]);
            newlim(2) = newlim(1)+xrange;
        end
    else
        if xlimits(2) >= max(self.time)
            return
        else
            newlim(2) = min([max(self.time) (xlimits(2)+.2*xrange)]);
            newlim(1) = newlim(2)-xrange;
        end
    end

    % update the scrollbar
    self.handles.scroll_bar.Value = newlim(1)/max(self.time);
end


% update the X and Y data since we don't want to show everything
a = find(self.time >= newlim(1), 1, 'first');
z = find(self.time <= newlim(2), 1, 'last');

for i = 1:length(self.handles.data)
    self.handles.ax(i).XLim = newlim;
    self.handles.data(i).XData = self.time(a:z);
    self.handles.data(i).YData = self.raw_data(a:z,i);
end

% xlim = get(s.handles.ax1,'XLim');
% if xlim(1) < min(self.time)
%     xlim(1) = min(self.time);
% end
% if xlim(2) > max(self.time)
%     xlim(2) = max(self.time);
% end
% xlim(2) = (floor(xlim(2)/s.pref.deltat))*s.pref.deltat;
% xlim(1) = (floor(xlim(1)/s.pref.deltat))*s.pref.deltat;
% ylim(2) = max(V(find(time==xlim(1)):find(time==xlim(2))));
% ylim(1) = min(V(find(time==xlim(1)):find(time==xlim(2))));
% yr = 2*std(V(find(time==xlim(1)):find(time==xlim(2))));
% if yr==0
%     set(s.handles.ax1,'YLim',[ylim(1)-1 ylim(2)+1]);
% else
%     set(s.handles.ax1,'YLim',[ylim(1)-yr ylim(2)+yr]);
% end
