function makeFindSpikesGUI(self,~,~)



% spin up a puppeteer instance by making a slider
% for every double property

if any(isnan(corelib.vectorise(self.sdp)))
	self.sdp = self.sdp.default;
end

[V, N] = corelib.vectorise(self.sdp);

rm_this = strcmp(N,'spike_sign');
N(rm_this) = [];
V(rm_this) = [];

lb = 0*V;
ub = 2*V + 1;

puppeteer_handle = puppeteer(N,V,lb,ub,[]);
puppeteer_handle.handles.fig.Name = 'Spike detection parameters';

puppeteer_handle.callback_function = @self.findSpikes;
puppeteer_handle.continuous_callback_function = @self.findSpikesInView;

self.handles.puppeteer_handle = puppeteer_handle;

self.findSpikes;