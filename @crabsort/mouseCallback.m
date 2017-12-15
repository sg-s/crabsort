
function mouseCallback(self,src,event)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% figure out which plot is being clicked on 
p = NaN(2,length(self.handles.ax));
for i = 1:length(self.handles.ax)
	temp = get(self.handles.ax(i),'CurrentPoint');
	p(:,i) = temp(1,1:2);
end
	
ylims = [self.handles.ax.YLim];
ylims = reshape(ylims,2,length(self.handles.ax));

this_ax =  find(p(2,:) > ylims(1,:) & p(2,:) < ylims(2,:));

if isempty(this_ax)
	return
end

self.channel_to_work_with = this_ax;

% p = get(self.handles.ax(1),'CurrentPoint');
% p = p(1,1:2);
% modify(s,p)
