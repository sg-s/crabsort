% plots the response

function [] = plotResp(s,src,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% when the raw voltage is set, we filter it (if need be), and display it
if s.filter_trace
    if s.verbosity
        cprintf('green','\n[INFO]')
        cprintf('text',' filtering trace...')
    end

    lc = floor(s.pref.band_pass(1)*1e-3/s.pref.deltat);
    hc = floor(s.pref.band_pass(2)*1e-3/s.pref.deltat);
    
    if any(isnan(s.raw_voltage))
        cprintf('red','\n[WARN] ')
        cprintf('NaNs found in voltage trace. Cannot continue.' )
        s.filtered_voltage = NaN*s.raw_voltage;
        s.LFP = NaN*s.raw_voltage; 
        set(s.handles.ax1_data,'XData',s.time,'YData',s.raw_voltage,'Color','k','Parent',s.handles.ax1);
        return
    end

    if s.pref.useFastBandPass

        [s.filtered_voltage,s.LFP] = fastBandPass(s.raw_voltage,lc,hc);
        error('this case is not usable yet. need to clean up trace...')
    else
        LFP = filtfilt(ones(lc,1),lc,s.raw_voltage);
        % now subtract the LFP from the raw voltage to get the spikes
        Vf = s.raw_voltage(:) - LFP(:);
        % clean it up; remove some HF noise
        s.filtered_voltage = filtfilt(ones(hc,1),hc,Vf);
        s.LFP = LFP;
    end

else
    % do nothing
end  

s.time = s.pref.deltat*(1:length(s.raw_voltage));

% and display it
if s.filter_trace
    set(s.handles.ax1_data,'XData',s.time,'YData',s.filtered_voltage,'Color','k','Parent',s.handles.ax1);
    if isempty(s.loc)
        % make sure we show the whole trace
        m = min(s.filtered_voltage);
        M = max(s.filtered_voltage);
        r = M - m;
        set(s.handles.ax1,'YLim',[m-r*.1 M+r*.1]);
    else
        % force an update
        s.loc = s.loc;
    end
else
    set(s.handles.ax1_data,'XData',s.time,'YData',s.raw_voltage,'Color','k','Parent',s.handles.ax1);

    % also fix the axes limits
    m = min(s.raw_voltage);
    M = max(s.raw_voltage);
    r = M - m;
    set(s.handles.ax1,'YLim',[m-r*.1 M+r*.1]);
end

% fix the axis
if all(get(s.handles.ax1,'XLim') == [0 1])
    set(s.handles.ax1,'XLim',[min(s.time) max(s.time)]);
end


