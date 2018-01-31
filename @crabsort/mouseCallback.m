
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% this function gets called every time the mouse is clicked

function mouseCallback(self,src,event)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

if ~isfield(self.handles,'ax')
	return
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

if this_ax == self.channel_to_work_with
	% still working with same channel, do things based
	% on the mode we are in manual_override
	self.modify(p(:,this_ax));

else
	% switch to new hcannel
	self.channel_to_work_with = this_ax;
end


