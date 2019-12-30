%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% moves plots when scroll wheel or scroll bar is moved

function scroll(self,src,event)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


if ~isfield(self.handles,'ax')
    return
end

this_ax_definitely_visible = find(strcmp({self.handles.ax.ax.Visible},'on'),1,'first');

xlimits = self.handles.ax.ax(this_ax_definitely_visible).XLim;
xrange = (xlimits(2) - xlimits(1));

if nargin == 3
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
elseif nargin == 2
    % treat the second argument as newlim
    newlim = src;
    % update the scrollbar
    self.handles.scroll_bar.Value = newlim(1)/max(self.time);
else
    error('unknown argument #')
end


% update the X and Y data since we don't want to show everything
a = find(self.time >= newlim(1), 1, 'first');
z = find(self.time <= newlim(2), 1, 'last');

for i = 1:length(self.handles.ax.data)
    if self.common.show_hide_channels(i)
        self.handles.ax.ax(i).XLim = newlim;
        self.handles.ax.data(i).XData = self.time(a:z);
        self.handles.ax.data(i).YData = self.raw_data(a:z,i).*self.mask(a:z,i);
    end
end

% if the current channel is intracellular, futz with the YLims to keep things in view
if isempty(self.channel_to_work_with)
    return
else
    channel = self.channel_to_work_with;
end

is_intracellular = any(isstrprop(self.common.data_channel_names{channel},'upper'));

if is_intracellular
    a = find(self.time >= self.handles.ax.ax(channel).XLim(1),1,'first');
    z = find(self.time >= self.handles.ax.ax(channel).XLim(2),1,'first');
    m = mean(self.raw_data(a:z,channel));
    yl = (self.handles.ylim_slider.Value)*100;
    if yl > 0
         self.handles.ax.ax(channel).YLim = [m-yl m+yl];
    end
   

end

drawnow limitrate