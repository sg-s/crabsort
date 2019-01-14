%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% makes the spikesort GUI

function self = makeGUI(self)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


f = get(0, 'Children');
for i = 1:length(f)
	assert(~strcmp(f(i).Tag,'crabsort_main_window'),'Crabsort window already exists, refusing to make a new GUI while that is open. Close all existing crabsort windows first.')
end

% make the master figure, and the axes to plot the voltage traces
handles.main_fig = figure('position',get( groot, 'Screensize' ), 'Toolbar','figure','Menubar','none','Name',self.version_name,'NumberTitle','off','IntegerHandle','off','WindowButtonDownFcn',@self.mouseCallback,'WindowScrollWheelFcn',@self.scroll,'CloseRequestFcn',@self.close,'Color','w','Tag','crabsort_main_window','ResizeFcn',@self.resize,'KeyPressFcn',@self.keyPressCallback);
temp =  findall(handles.main_fig,'Type','uitoggletool','-or','Type','uipushtool');

pool = gcp('nocreate');
if isempty(pool)
	parpool('local');
end

%delete(temp([2:5 7:8 11:15]))

% make a scrollbar at the bottom to quickly scroll
% through the traces

handles.scroll_bar = uicontrol(handles.main_fig,'units','normalized','Position',[.12 0 .85 .02],'Style', 'slider','callback',@self.scroll,'Visible','off');

addlistener(handles.scroll_bar,'ContinuousValueChange',@self.scroll);

% plots
handles.menu_name(1) = uimenu('Label','Make Plots...');
uimenu(handles.menu_name(1),'Label','Raster','Callback',@self.makeRaster);

% tools
handles.menu_name(2) = uimenu('Label','Tools');

uimenu(handles.menu_name(2),'Label','Reload preferences','Callback',@self.reloadPreferences);
uimenu(handles.menu_name(2),'Label','Reset current channel','Callback',@self.redo,'Separator','on');
uimenu(handles.menu_name(2),'Label','Ignore section','Callback',@self.ignoreSection,'Enable','on','Separator','on');
uimenu(handles.menu_name(2),'Label','UNignore section','Callback',@self.ignoreSection,'Enable','on','Separator','off');
uimenu(handles.menu_name(2),'Label','Update crabsort...','Callback',@self.update,'Enable','on','Separator','on');

% view
handles.menu_name(3) = uimenu('Label','View');
uimenu(handles.menu_name(3),'Label','Reset zoom','Callback',@self.resetZoom);
uimenu(handles.menu_name(3),'Label','Full trace','Callback',@self.showFullTrace,'Enable','on');

handles.menu_name(3) = uimenu('Label','Automate');

uimenu(handles.menu_name(3),'Label','All channels/All files','Callback',@self.automate,'Separator','off');
uimenu(handles.menu_name(3),'Label','This channel/All files','Callback',@self.automate,'Separator','on');
uimenu(handles.menu_name(3),'Label','All channels/This file','Callback',@self.automate,'Separator','on');
uimenu(handles.menu_name(3),'Label','Stop','Callback',@self.automate,'Separator','on');
uimenu(handles.menu_name(3),'Label','Stop when uncertain','Callback',@mtools.ux.toggleCheckedMenu,'Separator','on');


% neural network 
handles.menu_name(4) = uimenu('Label','Neural Network');
uimenu(handles.menu_name(4),'Label','Delete NN data on this channel','Callback',@self.NNdelete);
uimenu(handles.menu_name(4),'Label','Delete all NN data','Callback',@self.NNdelete);
uimenu(handles.menu_name(4),'Label','Delete this channels NN','Callback',@self.NNdelete,'Separator','on');
uimenu(handles.menu_name(4),'Label','Delete all nets','Callback',@self.NNdelete);
handles.auto_predict_handle = uimenu(handles.menu_name(4),'Label','Auto predict','Callback',@self.NNupdateAutoPredict,'Checked','on','Separator','on');
handles.NN_introspect_handle = uimenu(handles.menu_name(4),'Label','Inspect training data...','Callback',@self.NNintrospect,'Separator','on');


% channels (show and hide)
handles.menu_name(5) = uimenu('Label','Channels');



% file I/O panel
handles.data_panel = uipanel('Title','Select Data file','Position',[.01 .92 .15 .07],'BackgroundColor',[1 1 1],'FontSize',self.pref.fs);

uicontrol(handles.data_panel,'units','normalized','Position',[.05 .2 .2 .6],'Style', 'pushbutton', 'String', '<','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile,'Visible','off');

uicontrol(handles.data_panel,'units','normalized','Position',[.25 .1 .5 .8],'Style', 'pushbutton', 'String', 'Load File','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile,'Visible','on');

uicontrol(handles.data_panel,'units','normalized','Position',[.75 .2 .2 .6],'Style', 'pushbutton', 'String', '>','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile,'Visible','off');


% spike detection panel
handles.spike_detection_panel = uipanel('Title','Spike detection','Position',[0.16 .92 .15 .07],'BackgroundColor',[1 1 1],'Visible','off','FontSize',self.pref.fs);

handles.spike_sign_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.03 .03 .4 .7],'Style','togglebutton','String','+ve spikes','Value',1,'FontSize',self.pref.fs,'Callback',@self.toggleSpikeSign,'Enable','off');

handles.find_spikes_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.53 .03 .4 .7],'Style','pushbutton','String','Find spikes...','Value',1,'FontSize',self.pref.fs,'Callback',@self.makeFindSpikesGUI,'Enable','off');



% controls to configure the data to include in the reduction

handles.dim_red_panel = uipanel('Title','Dimensionality reduction','Position',[.31 .92 .18 .07],'BackgroundColor',[1 1 1],'Visible','off','FontSize',self.pref.fs);
handles.multi_channel_control = uicontrol(handles.dim_red_panel,'Style','checkbox','String','on','units','normalized','Position',[.01 .3 .18 .7],'Enable','on','FontSize',self.pref.fs,'BackgroundColor',[1 1 1],'Value',0);
handles.multi_channel_control_text = uicontrol(handles.dim_red_panel,'Style','edit','String','','units','normalized','Position',[.15 .15 .15 .7],'Enable','on','FontSize',self.pref.fs,'BackgroundColor',[1 1 1]);

all_plugin_names = {self.installed_plugins.name};
dim_red_plugins = all_plugin_names(find(strcmp({self.installed_plugins.plugin_type},'dim-red')));

handles.method_control = uicontrol(handles.dim_red_panel,'Style','popupmenu','String',dim_red_plugins,'units','normalized','Position',[.65 .04 .34 .9],'Callback',@self.reduceDimensionsCallback,'FontSize',self.pref.fs);



handles.cluster_panel = uipanel('Title','Cluster & Sort','Position',[.49 .92 .12 .07],'BackgroundColor',[1 1 1],'Visible','off','FontSize',self.pref.fs);

% find the available methods for clustering
all_plugin_names = {self.installed_plugins.name};
cluster_plugins = all_plugin_names(find(strcmp({self.installed_plugins.plugin_type},'cluster')));

handles.cluster_control = uicontrol(handles.cluster_panel,'Style','popupmenu','String',cluster_plugins,'units','normalized','Position',[.02 .6 .9 .2],'Callback',@self.clusterCallback,'FontSize',self.pref.fs);


% mask panel
handles.mask_panel = uibuttongroup(handles.main_fig,'Title','Masking','Position',[.61 .92 .19 .07],'FontSize',self.pref.fs,'Visible','on','BackgroundColor',[ 1 1 1]);
handles.maskmode_mask = uicontrol(handles.mask_panel,'units','normalized','Position',[.01 .5 .2 .5], 'Style', 'radiobutton', 'String', 'Mask','FontSize',self.pref.fs,'BackgroundColor',[1 1 1]);
handles.maskmode_unmask = uicontrol(handles.mask_panel,'units','normalized','Position',[.31 .5 .2 .5], 'Style', 'radiobutton', 'String', 'Unmask','FontSize',self.pref.fs,'BackgroundColor',[1 1 1]);
handles.maskmode_off = uicontrol(handles.mask_panel,'units','normalized','Position',[.71 .5 .2 .5], 'Style', 'radiobutton', 'String', 'Off','FontSize',self.pref.fs,'BackgroundColor',[1 1 1]);
handles.mask_all_control = uicontrol(handles.mask_panel,'units','normalized','Position',[.01 .01 .3 .5], 'Style', 'pushbutton', 'String', 'Mask all','FontSize',self.pref.fs,'Callback',@self.maskUnmask);
handles.unmask_all_control = uicontrol(handles.mask_panel,'units','normalized','Position',[.51 .01 .3 .5], 'Style', 'pushbutton', 'String', 'Unmask all','FontSize',self.pref.fs,'Callback',@self.maskUnmask);
handles.maskmode_off.Value = 1;

% manual override panel
handles.manual_panel = uibuttongroup(handles.main_fig,'Title','Manual Override','Position',[.8 .92 .195 .07],'FontSize',self.pref.fs,'Visible','on','BackgroundColor',[ 1 1 1]);
handles.mark_all_control = uicontrol(handles.manual_panel,'units','normalized','Position',[.01 .01 .4 .5], 'Style', 'popupmenu', 'String', {'Mark all in view as...'},'FontSize',self.pref.fs,'BackgroundColor',[1 1 1],'Callback',@self.markAllInViewAs);
handles.mode_new_spike = uicontrol(handles.manual_panel,'units','normalized','Position',[.01 .5 .2 .5], 'Style', 'radiobutton', 'String', 'add to','FontSize',self.pref.fs,'BackgroundColor',[1 1 1]);
handles.new_spike_type = uicontrol(handles.manual_panel,'units','normalized','Position',[.2 .5 .3 .5], 'Style', 'popupmenu', 'String', {'Choose'},'FontSize',self.pref.fs,'BackgroundColor',[1 1 1],'Callback',@self.activateAddNewNeuronMode);
handles.mode_off = uicontrol(handles.manual_panel,'units','normalized','Position',[.71 .25 .3 .5], 'Style', 'radiobutton', 'String', 'Off','FontSize',self.pref.fs,'BackgroundColor',[1 1 1],'Value',1);


% make a pop-over for busy messages
handles.popup = uicontrol('parent',handles.main_fig,'units','normalized','Position',[0 0 1 1],'Style', 'text', 'String', {'','','','','','','','Embedding...'},'FontSize',self.pref.fs*3,'FontWeight','normal','Visible','off','BackgroundColor',[1 1 1]);


% create a timer to read the progress of the parallel worker
self.timer_handle = timer('TimerFcn',@self.NNtimer,'ExecutionMode','fixedDelay','TasksToExecute',Inf,'Period',.5,'ErrorFcn',@self.NNerror);

self.handles = handles;