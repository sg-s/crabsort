function [] = killRinging(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end


V = s.filtered_voltage;
Fs = 1/s.pref.deltat; 


% FFT it
L = length(V);
NFFT = 2^nextpow2(L);

Y = fft(V,NFFT)/L;
f = Fs/2*[linspace(0,1,NFFT/2) linspace(1,0,NFFT/2)]; 

% now, cut out the maximum freqyency
[~,idx] = max(abs(Y));
peak_freq = f(idx);

if s.verbosity > 9
	figure('outerposition',[0 0 1000 500],'PaperUnits','points','PaperSize',[1000 500]); hold on
	ax1 = subplot(1,4,1); hold on
	plot(f,abs(Y),'k')
	set(gca,'XScale','log')
	xlabel('frequency (Hz)')
	ylabel('|F|')

	ax2 = subplot(1,4,2:4); hold on
	plot(V,'k')

end

if s.verbosity > 0
	cprintf('green','\n[INFO] ')
    cprintf('text',['Peak frequency in signal is: ' oval(peak_freq) ' Hz'])
end


notch_min = floor(peak_freq) - .5;
notch_max = ceil(peak_freq) + 1;
a = find(f>notch_min,1,'first');
z = find(f>notch_max,1,'first');
Y(a:z) = interp1([a-1 z+1],Y([a-1 z+1]),a:z);

a = find(f>notch_max,1,'last');
z = find(f>notch_min,1,'last');
Y(a:z) = interp1([a-1 z+1],Y([a-1 z+1]),a:z);

if s.verbosity > 9
	plot(ax1,f,abs(Y),'r')
end

% inverse transform it
yhat = ifft(Y);

% cut it 
yhat = length(V)*yhat(1:length(V));
if s.verbosity > 9
	plot(ax2,real(yhat),'r')
	legend({'Original signal','After killing ringing'})
end

s.filtered_voltage = real(yhat);

set(s.handles.ax1_data,'XData',s.time,'YData',real(yhat),'Color','k','Parent',s.handles.ax1);

s.findSpikes;