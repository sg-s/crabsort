
function modify(s,p)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% compatability layer
A = s.A(:);
B = s.B(:);
V = s.filtered_voltage(:);

% check that the point is within the axes
ylimits = get(s.handles.ax1,'YLim');
if p(2) > ylimits(2) || p(2) < ylimits(1)
    % console('Rejecting point: Y exceeded')
    return
end
xlimits = get(s.handles.ax1,'XLim');
if p(1) > xlimits(2) || p(1) < xlimits(1)
    % console('Rejecting point: X exceeded')
    return
end

p(1) = p(1)/s.pref.deltat;
xrange = (xlimits(2) - xlimits(1))/s.pref.deltat;
yrange = ylimits(2) - ylimits(1);
% get the width over which to search for spikes dynamically from the zoom factor
search_width = floor((.005*xrange));
if get(s.handles.mode_new_A,'Value') == 1
    % snip out a small waveform around the point
    if s.pref.invert_V
        [~,loc] = min(V(floor(p(1)-search_width:p(1)+search_width)));
    else
        [~,loc] = max(V(floor(p(1)-search_width:p(1)+search_width)));
    end
    A = [A; -search_width+loc+floor(p(1))];

elseif get(s.handles.mode_new_B,'Value')==1
    % snip out a small waveform around the point
    if s.pref.invert_V
        [~,loc] = min(V(floor(p(1)-search_width:p(1)+search_width)));
    else
        [~,loc] = max(V(floor(p(1)-search_width:p(1)+search_width)));
    end
    B = [B; -search_width+loc+floor(p(1))];

elseif get(s.handles.mode_delete,'Value') == 1
    if isempty(A) & isempty(B)
        % ok, need to remove a identified peak, not a classified spike
        loc = s.loc(:);
        dloc = (((loc-p(1))/(xrange)).^2  + ((V(loc) - p(2))/(5*yrange)).^2);
        [~,closest_spike] = min(dloc);
        loc(closest_spike) = [];
        s.V_snippets(:,closest_spike) = [];
        s.loc = loc;
    else
        % find the closest spike
        dA = (((A-p(1))/(xrange)).^2  + ((V(A) - p(2))/(5*yrange)).^2);
        dB = (((B-p(1))/(xrange)).^2  + ((V(B) - p(2))/(5*yrange)).^2);

        dist_to_A = min(dA);
        dist_to_B = min(dB);
        if dist_to_A < dist_to_B
            [~,closest_spike] = min(dA);
            A(closest_spike) = [];
        else
            [~,closest_spike] = min(dB);
            B(closest_spike) = [];
        end
    end
elseif get(s.handles.mode_A2B,'Value') == 1 
% find the closest B spike
    dA = (((A-p(1))/(xrange)).^2  + ((V(A) - p(2))/(5*yrange)).^2);
    [~,closest_spike] = min(dA);
    B = [B; A(closest_spike)];
    A(closest_spike) = [];

elseif get(s.handles.mode_B2A,'Value') == 1
    % find the closest B spike
    dB = (((B-p(1))/(xrange)).^2  + ((V(B) - p(2))/(5*yrange)).^2);
    [~,closest_spike] = min(dB);
    A = [A; B(closest_spike)];
    B(closest_spike) = [];

end

s.A = A;
s.B = B;

