function NNintrospect(self, src, event)

if nargin == 3
	switch event.EventName
	case 'Close'
		delete(self.handles.NNdata_inspector)
		return
	case 'WindowMousePress'
		p = get(self.handles.NNdata_inspector_ax,'CurrentPoint');

		return
	end


end

if isempty(self.channel_to_work_with)
	return
else
	channel = self.channel_to_work_with;
end


% make the UI if needed
if isfield(self.handles,'NNdata_inspector') && isvalid(self.handles.NNdata_inspector)
else
	% make figure

	self.handles = rmfield(self.handles,'NNdata_inspector');
	self.handles = rmfield(self.handles,'NNdata_inspector_tsne');
	self.handles = rmfield(self.handles,'NNdata_inspector_ax');
	self.handles = rmfield(self.handles,'NNdata_inspector_tsne_noise');

	self.handles.NNdata_inspector = figure('position',[10 10 800 800], 'Toolbar','figure','Menubar','none','Name','Inspecting training data...','NumberTitle','off','IntegerHandle','off','WindowButtonDownFcn',@self.NNintrospect,'CloseRequestFcn',@self.NNintrospect,'Color','w','Tag','NNdata_inspector','KeyPressFcn',@self.NNintrospect);

	self.handles.NNdata_inspector_ax = axes(self.handles.NNdata_inspector);
	hold(self.handles.NNdata_inspector_ax,'on')
	axis(self.handles.NNdata_inspector_ax','off')

	c = lines;
	for i = 10:-1:1
		self.handles.NNdata_inspector_tsne(i) = plot(self.handles.NNdata_inspector_ax,NaN,NaN,'.','Color',c(i,:),'MarkerSize',24);
	end
	self.handles.NNdata_inspector_tsne_noise = plot(self.handles.NNdata_inspector_ax,NaN,NaN,'o','Color',[.5 .5 .5]);
end


% prep the data
X = self.common.NNdata(channel).raw_data;
L = self.common.NNdata(channel).label_idx;
R = tsne(X');

% plot
self.handles.NNdata_inspector_tsne_noise.XData = R(L==0,1);
self.handles.NNdata_inspector_tsne_noise.YData = R(L==0,2);

uL = unique(L);
uL = nonzeros(uL);
for i = 1:length(uL)
	self.handles.NNdata_inspector_tsne(i).XData = R(L==i,1);
	self.handles.NNdata_inspector_tsne(i).YData = R(L==i,2);
end

