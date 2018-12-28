%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% master dispatched when we want to reduce dimensions

function reduceDimensionsCallback(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    d = dbstack;
    cprintf('text',[mfilename ' called by ' d(2).name])
end


method = (get(self.handles.method_control,'Value'));
temp = get(self.handles.method_control,'String');
method = temp{method};
method = str2func(method);


self.handles.popup.Visible = 'on';
self.handles.popup.String = {'','','','Reducing Dimensions...'};
drawnow;


% make sure putative spikes is populated
if ~any(self.putative_spikes(:,self.channel_to_work_with))

	already_sorted_spikes = self.getSpikesOnThisNerve;
	assert(any(already_sorted_spikes),'No putative spikes, no already sorted spikes. crabsort cant reduce dimensions on nothing. Try finding some spikes first.')

	self.putative_spikes(:,self.channel_to_work_with) = already_sorted_spikes;
end


% get the data to reduce
self.getDataToReduce; 


% create an operation manifest BEFORE calling the method so that
% the method can modify, or add onto the operation. 
if self.watch_me 

	% create a description of the operations we just did 


	this_channel = self.channel_to_work_with;

	self.common.NNdata(this_channel).other_nerves = self.handles.multi_channel_control_text.String;
	self.common.NNdata(this_channel).other_nerves_control = logical(self.handles.multi_channel_control.Value);



end



method(self);

self.handles.popup.Visible = 'off';


% change the marker on the identified spikes
idx = self.channel_to_work_with;
set(self.handles.ax.found_spikes(idx),'Marker','o','Color',self.pref.embedded_spike_colour,'LineStyle','none')
drawnow;

self.channel_stage(idx) = 2; 

self.handles.main_fig.Name = [self.file_name '  -- Dimensions reduced using ' func2str(method)]

