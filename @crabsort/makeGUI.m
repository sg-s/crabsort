%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% makes the spikesort GUI

function self = makeGUI(self)

if self.verbosity > 9
	disp(mfilename)
end

f = get(0, 'Children');
for i = 1:length(f)
	assert(~strcmp(f(i).Tag,'crabsort_main_window'),'Crabsort window already exists, refusing to make a new GUI while that is open. Close all existing crabsort windows first.')
end

assert(logical(license('test','Neural_Network_Toolbox')),'No license found for Neural Network Toolbox')

% make the master figure, and the axes to plot the voltage traces
handles.main_fig = figure('position',get( groot, 'Screensize' ), 'Toolbar','figure','Menubar','none','Name',self.version_name,'NumberTitle','off','IntegerHandle','off','WindowButtonDownFcn',@self.mouseCallback,'WindowScrollWheelFcn',@self.scroll,'CloseRequestFcn',@self.close,'Color','w','Tag','crabsort_main_window','ResizeFcn',@self.resize,'KeyPressFcn',@self.keyPressCallback);

pool = gcp('nocreate');
if isempty(pool)
	parpool('local');
end
pool = gcp('nocreate');
self.NumWorkers = pool.NumWorkers;

%delete(temp([2:5 7:8 11:15]))

% make a scrollbar at the bottom to quickly scroll
% through the traces

handles.scroll_bar = uicontrol(handles.main_fig,'units','normalized','Position',[.12 0 .85 .02],'Style', 'slider','callback',@self.scroll,'Visible','off');

addlistener(handles.scroll_bar,'ContinuousValueChange',@self.scroll);

% plots
handles.menu_name(1) = uimenu('Label','Make Plots...');
uimenu(handles.menu_name(1),'Label','Raster','Callback',@self.makeRaster);
uimenu(handles.menu_name(1),'Label','Plot ISIs','Callback',@self.makeISIPlot);

% tools
handles.menu_name(2) = uimenu('Label','Tools');

uimenu(handles.menu_name(2),'Label','Reload preferences','Callback',@self.reloadPreferences);
uimenu(handles.menu_name(2),'Label','Reset current channel','Callback',@self.redo,'Separator','on');
uimenu(handles.menu_name(2),'Label','Mark channel as having no spikes','Callback',@self.zeroSpikes);

% view
handles.menu_name(3) = uimenu('Label','View');
uimenu(handles.menu_name(3),'Label','Reset zoom','Callback',@self.resetZoom);
uimenu(handles.menu_name(3),'Label','Full trace','Callback',@self.showFullTrace,'Enable','on');

% automate
handles.menu_name(4) = uimenu('Label','Automate');
uimenu(handles.menu_name(4),'Label','Start','Callback',@self.automate,'Separator','off');
uimenu(handles.menu_name(4),'Label','Stop','Callback',@self.automate,'Separator','off');

uimenu(handles.menu_name(4),'Label','Stopping condition','Separator','on','Enable','off');
uimenu(handles.menu_name(4),'Label','Stop when uncertain','Callback',@uxlib.toggleCheckedMenu,'Separator','off');
uimenu(handles.menu_name(4),'Label','Stop when data exceeds YLim','Callback',@uxlib.toggleCheckedMenu,'Separator','off');
uimenu(handles.menu_name(4),'Label','Stop if artifacts are marked','Callback',@uxlib.toggleCheckedMenu,'Separator','off');

uimenu(handles.menu_name(4),'Label','Automate action','Separator','on','Enable','off');
% make a menu option for each automateAction
possible_actions = (enumeration('crabsort.automateAction'));
for i = 1:length(possible_actions)
	if strcmp(char(possible_actions(i)),'none')
		continue
	end
	L = strrep(char(possible_actions(i)),'_',' ');
	uimenu(handles.menu_name(4),'Label',L,'Callback',@self.automate,'Separator','off');

end




uimenu(handles.menu_name(4),'Label','mark data outside YLim as artifacts','Callback',@uxlib.toggleCheckedMenu,'Separator','on');
uimenu(handles.menu_name(4),'Label','Overwrite previous predictions','Callback',@uxlib.toggleCheckedMenu,'Separator','on');


% neural network 
handles.menu_name(5) = uimenu('Label','Neural Network');
uimenu(handles.menu_name(5),'Label','Delete NN data on this channel','Callback',@self.NNdelete);
uimenu(handles.menu_name(5),'Label','Delete all NN data','Callback',@self.NNdelete);
uimenu(handles.menu_name(5),'Label','Delete this channels NN','Callback',@self.NNdelete,'Separator','on');
uimenu(handles.menu_name(5),'Label','Delete all nets','Callback',@self.NNdelete);
handles.auto_predict_handle = uimenu(handles.menu_name(5),'Label','Auto predict','Callback',@self.NNupdateAutoPredict,'Checked','on','Separator','on');
handles.add_uncertain = uimenu(handles.menu_name(5),'Label','Add uncertain and relabelled spikes to training data...','Callback',@self.NNaddAllUncertainSpikes,'Separator','on');
handles.purge_uncertain_spikes = uimenu(handles.menu_name(5),'Label','Purge uncertain spikes...','Callback',@self.purgeUncertainSpikes,'Separator','on');
handles.NN_introspect_handle = uimenu(handles.menu_name(5),'Label','Inspect training data...','Callback',@self.NNintrospect,'Separator','on');


% channels (show and hide)
handles.menu_name(6) = uimenu('Label','Channels');

% artifacts
handles.menu_name(7) = uimenu('Label','Artifacts');
uimenu(handles.menu_name(7),'Label','Ignore this section','Callback',@self.ignoreSection,'Separator','off');
uimenu(handles.menu_name(7),'Label','UNignore this section','Callback',@self.ignoreSection,'Separator','off');
uimenu(handles.menu_name(7),'Label','Ignore sections where data exceeds Y bounds','Callback',@self.ignoreSection,'Separator','on');
uimenu(handles.menu_name(7),'Label','Mark all data BEFORE this file as useless','Callback',@self.ignoreEntireFiles,'Separator','on');
uimenu(handles.menu_name(7),'Label','Mark all data AFTER this file as useless','Callback',@self.ignoreEntireFiles,'Separator','off');

% file I/O panel
handles.data_panel = uipanel('Title','Select Data file','Position',[.01 .92 .15 .07],'BackgroundColor',[1 1 1],'FontSize',self.pref.fs);

handles.prev_file_control = uicontrol(handles.data_panel,'units','normalized','Position',[.05 .2 .2 .6],'Style', 'pushbutton', 'String', '<','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile,'Visible','off');

uicontrol(handles.data_panel,'units','normalized','Position',[.25 .1 .5 .8],'Style', 'pushbutton', 'String', 'Load File','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile,'Visible','on');

handles.next_file_control = uicontrol(handles.data_panel,'units','normalized','Position',[.75 .2 .2 .6],'Style', 'pushbutton', 'String', '>','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile,'Visible','off');


% spike detection panel
handles.spike_detection_panel = uipanel('Title','Spike detection','Position',[0.16 .92 .15 .07],'BackgroundColor',[1 1 1],'Visible','off','FontSize',self.pref.fs);

handles.spike_sign_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.03 .03 .4 .7],'Style','togglebutton','String','+ve spikes','Value',1,'FontSize',self.pref.fs,'Callback',@self.toggleSpikeSign,'Enable','off');

handles.find_spikes_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.53 .03 .4 .7],'Style','pushbutton','String','Find spikes...','Value',1,'FontSize',self.pref.fs,'Callback',@self.makeFindSpikesGUI,'Enable','off');



% controls to configure the data to include in the reduction

handles.dim_red_panel = uipanel('Title','Dimensionality reduction','Position',[.31 .92 .18 .07],'BackgroundColor',[1 1 1],'Visible','off','FontSize',self.pref.fs);
handles.multi_channel_control = uicontrol(handles.dim_red_panel,'Style','checkbox','String','on','units','normalized','Position',[.01 .3 .18 .7],'Enable','on','FontSize',self.pref.fs,'BackgroundColor',[1 1 1],'Value',0);
handles.multi_channel_control_text = uicontrol(handles.dim_red_panel,'Style','edit','String','','units','normalized','Position',[.15 .15 .15 .7],'Enable','on','FontSize',self.pref.fs,'BackgroundColor',[1 1 1]);


handles.method_control = uicontrol(handles.dim_red_panel,'Style','popupmenu','String',self.installed_plugins.csRedDim,'units','normalized','Position',[.65 .04 .34 .9],'Callback',@self.reduceDimensionsCallback,'FontSize',self.pref.fs);



handles.cluster_panel = uipanel('Title','Cluster & Sort','Position',[.49 .92 .12 .07],'BackgroundColor',[1 1 1],'Visible','off','FontSize',self.pref.fs);


handles.cluster_control = uicontrol(handles.cluster_panel,'Style','popupmenu','String',self.installed_plugins.csCluster,'units','normalized','Position',[.02 .6 .9 .2],'Callback',@self.clusterCallback,'FontSize',self.pref.fs);


% mask panel
handles.mask_panel = uibuttongroup(handles.main_fig,'Title','Per-channel Masking','Position',[.61 .92 .19 .07],'FontSize',self.pref.fs,'Visible','on','BackgroundColor',[ 1 1 1]);

handles.mask_all_control = uicontrol(handles.mask_panel,'units','normalized','Position',[.01 .1 .2 .8], 'Style', 'pushbutton', 'String', 'Mask all','FontSize',self.pref.fs,'Callback',@self.maskUnmask);
handles.mask_all_but_view_control = uicontrol(handles.mask_panel,'units','normalized','Position',[.22 .1 .45 .8], 'Style', 'pushbutton', 'String', 'Mask all outside view','FontSize',self.pref.fs,'Callback',@self.maskUnmask);
handles.unmask_all_control = uicontrol(handles.mask_panel,'units','normalized','Position',[.68 .1 .3 .8], 'Style', 'pushbutton', 'String', 'Unmask all','FontSize',self.pref.fs,'Callback',@self.maskUnmask);


% manual override panel
handles.manual_panel = uibuttongroup(handles.main_fig,'Title','Manual Override','Position',[.8 .92 .195 .07],'FontSize',self.pref.fs,'Visible','on','BackgroundColor',[ 1 1 1]);
handles.mark_all_control = uicontrol(handles.manual_panel,'units','normalized','Position',[.01 .01 .4 .5], 'Style', 'popupmenu', 'String', {'Mark all in view as...'},'FontSize',self.pref.fs,'BackgroundColor',[1 1 1],'Callback',@self.markAllInViewAs);
handles.mode_new_spike = uicontrol(handles.manual_panel,'units','normalized','Position',[.01 .5 .2 .5], 'Style', 'radiobutton', 'String', 'add to','FontSize',self.pref.fs,'BackgroundColor',[1 1 1],'Callback',@self.updateCursor);
handles.new_spike_type = uicontrol(handles.manual_panel,'units','normalized','Position',[.2 .5 .3 .5], 'Style', 'popupmenu', 'String', {'Choose'},'FontSize',self.pref.fs,'BackgroundColor',[1 1 1],'Callback',@self.activateAddNewNeuronMode);
handles.mode_off = uicontrol(handles.manual_panel,'units','normalized','Position',[.71 .25 .3 .5], 'Style', 'radiobutton', 'String', 'Off','FontSize',self.pref.fs,'BackgroundColor',[1 1 1],'Value',1,'Callback',@self.updateCursor);


% make a pop-over for busy messages
handles.popup = uicontrol('parent',handles.main_fig,'units','normalized','Position',[0 0 1 1],'Style', 'text', 'String', {'','','','','','','','Embedding...'},'FontSize',self.pref.fs*3,'FontWeight','normal','Visible','off','BackgroundColor',[1 1 1]);


% create a timer to read the progress of the parallel worker
self.timer_handle = timer('TimerFcn',@self.NNtimer,'ExecutionMode','fixedDelay','TasksToExecute',Inf,'Period',1);

self.handles = handles;



% cancel all outstanding futures on parallel pool
a = gcp;
cancel(a.FevalQueue.RunningFutures)
cancel(a.FevalQueue.QueuedFutures)