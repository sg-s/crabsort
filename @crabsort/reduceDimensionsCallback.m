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

method(self);

self.handles.popup.Visible = 'off';

% change the marker on the identified spikes
idx = self.channel_to_work_with;
set(self.handles.found_spikes(idx),'Marker','o','Color',self.pref.embedded_spike_colour,'LineStyle','none')
drawnow;

self.channel_stage(idx) = 2; 