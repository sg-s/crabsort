function makeFindSpikesGUI(self,~,~)



% spin up a puppeteer instance by making a slider
% for every double property
props = properties(self.spd);
N = {};
V = [];
for i = 1:length(props)
	if isa(self.spd.(props{i}),'double')
		N{end+1} = props{i};
		V(end+1) = self.spd.(props{i});
	end
end


lb = 0*V;
ub = 2*V + 1;

puppeteer_handle = puppeteer(N,V,lb,ub,[]);
puppeteer_handle.handles.fig.Name = 'Spike detection parameters';

puppeteer_handle.callback_function = @self.findSpikes;
puppeteer_handle.continuous_callback_function = @self.findSpikesInView;

self.handles.puppeteer_handle = puppeteer_handle;