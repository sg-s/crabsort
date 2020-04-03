function makeFindSpikesGUI(self,~,~)

if self.verbosity > 9
	disp(mfilename)
end

% spin up a puppeteer instance by making a slider
% for every double property

if any(isnan(corelib.vectorise(self.sdp)))
	disp('resetting SDP')
	self.sdp = self.sdp.default;
end

if self.isIntracellular(self.channel_to_work_with)
	self.sdp.MinPeakHeight = -80;
	self.sdp.MaxPeakHeight = 200;
	self.sdp.MinPeakDistance = 5;
end


[V, N] = corelib.vectorise(self.sdp);

rm_this = strcmp(N,'spike_sign');
N(rm_this) = [];
V(rm_this) = [];


lb = 0*V;
ub = 2*V + 1;

puppeteer_handle = puppeteer(N,V,lb,ub,[]);
puppeteer_handle.handles.fig.Name = 'Spike detection parameters';

puppeteer_handle.valueChangedFcn = @self.findSpikes;
puppeteer_handle.valueChangingFcn = @self.findSpikesInView;

self.handles.puppeteer_handle = puppeteer_handle;

self.findSpikes;