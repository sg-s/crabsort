
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% this function gets called every time the mouse is clicked

function mouseCallback(self,src,event)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


if ~isfield(self.handles,'ax')
	return
end


% figure out which plot is being clicked on 
p = NaN(2,length(self.handles.ax.ax));
ylims = NaN(2,length(self.handles.ax.ax));
for i = 1:length(self.handles.ax.ax)
	try
		if strcmp(self.handles.ax.ax(i).Visible,'on')
			temp = get(self.handles.ax.ax(i),'CurrentPoint');
			p(:,i) = temp(1,1:2);
			ylims(:,i) = self.handles.ax.ax(i).YLim;
		end
	catch err
		for ei = 1:length(err)
            err.stack(ei)
        end
	end
end
	

this_ax =  find(p(2,:) > ylims(1,:) & p(2,:) < ylims(2,:));

if isempty(this_ax)
	return
end

if ~isempty(self.channel_to_work_with) && this_ax == self.channel_to_work_with
	% still working with same channel, do things based
	% on the mode we are in manual_override
	self.modify(p(:,this_ax));

else
	% switch to new channel
	self.channel_to_work_with = this_ax;
end


