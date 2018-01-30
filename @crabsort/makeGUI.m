%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% makes the spikesort GUI

function self = makeGUI(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% make the master figure, and the axes to plot the voltage traces
handles.main_fig = figure('position',get( groot, 'Screensize' ), 'Toolbar','figure','Menubar','none','Name',self.version_name,'NumberTitle','off','IntegerHandle','off','WindowButtonDownFcn',@self.mouseCallback,'WindowScrollWheelFcn',@self.scroll,'CloseRequestFcn',@self.close,'Color','w');
temp =  findall(handles.main_fig,'Type','uitoggletool','-or','Type','uipushtool');
delete(temp([1:5 7:8 11:15]))

% make a scrollbar at the bottom to quickly scroll
% through the traces

handles.scroll_bar = uicontrol(handles.main_fig,'units','normalized','Position',[.1 0 .89 .02],'Style', 'slider','callback',@self.scroll,'Visible','off');

addlistener(handles.scroll_bar,'ContinuousValueChange',@self.scroll);

% plots
handles.menu_name(1) = uimenu('Label','Make Plots...');
uimenu(handles.menu_name(1),'Label','Raster','Callback',@self.makeRaster);

% tools
handles.menu_name(2) = uimenu('Label','Tools');

uimenu(handles.menu_name(2),'Label','Reload preferences','Callback',@self.reloadPreferences);
uimenu(handles.menu_name(2),'Label','Reset current channel','Callback',@self.redo,'Separator','on');

% view
handles.menu_name(3) = uimenu('Label','View');
uimenu(handles.menu_name(3),'Label','Reset zoom','Callback',@self.resetZoom);
uimenu(handles.menu_name(3),'Label','Full trace','Callback',@self.showFullTrace);

handles.menu_name(3) = uimenu('Label','Automate');
uimenu(handles.menu_name(3),'Label','Watch me','Checked','on','Callback',@self.updateWatchMe);
uimenu(handles.menu_name(3),'Label','Run on this channel','Callback',@self.automate,'Separator','on');
uimenu(handles.menu_name(3),'Label','Run on this file','Callback',@self.automate,'Separator','off');
uimenu(handles.menu_name(3),'Label','Run on all files...','Callback',@self.automate);

uimenu(handles.menu_name(3),'Label','Delete ALL automate info','Callback',@self.deleteAllAutomateInfo,'Separator','on');
uimenu(handles.menu_name(3),'Label','Delete automate info for this channel','Callback',@self.deleteAllAutomateInfo);

% tensorflow 
% handles.menu_name(4) = uimenu('Label','Tensorflow');
% uimenu(handles.menu_name(4),'Label','Train network','Callback',@self.train);
% uimenu(handles.menu_name(4),'Label','Predict','Callback',@self.predict);
% uimenu(handles.menu_name(4),'Label','Clear TF Data','Callback',@self.clearTFData,'Separator','on');
% uimenu(handles.menu_name(4),'Label','Delete Neural Network','Callback',@self.deleteTFNetwork,'Separator','on');


% file I/O panel
handles.data_panel = uipanel('Title','Select Data file','Position',[.01 .92 .12 .07],'BackgroundColor',[1 1 1],'FontSize',self.pref.fs);

uicontrol(handles.data_panel,'units','normalized','Position',[.05 .2 .2 .6],'Style', 'pushbutton', 'String', '<','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile,'Visible','off');

uicontrol(handles.data_panel,'units','normalized','Position',[.25 .1 .5 .8],'Style', 'pushbutton', 'String', 'Load File','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile,'Visible','on');

uicontrol(handles.data_panel,'units','normalized','Position',[.75 .2 .2 .6],'Style', 'pushbutton', 'String', '>','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile,'Visible','off');


% spike detection panel
handles.spike_detection_panel = uipanel('Title','Spike detection','Position',[.135 .92 .2 .07],'BackgroundColor',[1 1 1],'Visible','off','FontSize',self.pref.fs);

handles.prom_ub_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.85 .65 .1 .4],'Style','edit','String','1','FontSize',self.pref.fs,'Callback',@self.updateSpikePromSlider,'Enable','off');
handles.spike_prom_slider = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.01 .63 .8 .25],'Style','Slider','Min',0,'Max',1,'Value',.5,'Callback',@self.findSpikes,'Enable','off');
try    % R2013b and older
   addlistener(handles.spike_prom_slider,'ActionEvent',@self.findSpikes);
catch  % R2014a and newer
   addlistener(handles.spike_prom_slider,'ContinuousValueChange',@self.findSpikes);
end

handles.spike_sign_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.01 .01 .4 .4],'Style','togglebutton','String','Finding +ve spikes','Value',1,'FontSize',self.pref.fs,'Callback',@self.toggleSpikeSign,'Enable','off');



handles.dim_red_panel = uipanel('Title','Dimensionality reduction','Position',[.34 .92 .35 .07],'BackgroundColor',[1 1 1],'Visible','off','FontSize',self.pref.fs);

% controls to configure the data to include in the reduction
handles.spike_shape_control = uicontrol(handles.dim_red_panel,'Style','checkbox','String','Spike shape','units','normalized','Position',[.01 .05 .18 .9],'Enable','on','FontSize',self.pref.fs,'BackgroundColor',[1 1 1],'Value',1);

handles.time_after_control = uicontrol(handles.dim_red_panel,'Style','checkbox','String','Time after','units','normalized','Position',[.2 .0 .2 .5],'Enable','on','FontSize',self.pref.fs,'BackgroundColor',[1 1 1]);
handles.time_after_nerves = uicontrol(handles.dim_red_panel,'Style','edit','String','','units','normalized','Position',[.4 .0 .2 .5],'Enable','on','FontSize',self.pref.fs,'BackgroundColor',[1 1 1]);

handles.time_before_control = uicontrol(handles.dim_red_panel,'Style','checkbox','String','Time before','units','normalized','Position',[.2 .5 .2 .5],'Enable','on','FontSize',self.pref.fs,'BackgroundColor',[1 1 1]);
handles.time_before_nerves = uicontrol(handles.dim_red_panel,'Style','edit','String','','units','normalized','Position',[.4 .5 .2 .5],'Enable','on','FontSize',self.pref.fs,'BackgroundColor',[1 1 1]);

all_plugin_names = {self.installed_plugins.name};
dim_red_plugins = all_plugin_names(find(strcmp({self.installed_plugins.plugin_type},'dim-red')));

handles.method_control = uicontrol(handles.dim_red_panel,'Style','popupmenu','String',dim_red_plugins,'units','normalized','Position',[.61 .04 .34 .9],'Callback',@self.reduceDimensionsCallback,'FontSize',20);



handles.cluster_panel = uipanel('Title','Cluster & Sort','Position',[.82 .92 .12 .07],'BackgroundColor',[1 1 1],'Visible','off','FontSize',self.pref.fs);

% find the available methods for clustering
all_plugin_names = {self.installed_plugins.name};
cluster_plugins = all_plugin_names(find(strcmp({self.installed_plugins.plugin_type},'cluster')));

handles.cluster_control = uicontrol(handles.cluster_panel,'Style','popupmenu','String',cluster_plugins,'units','normalized','Position',[.02 .6 .9 .2],'Callback',@self.clusterCallback,'FontSize',20);



% make a pop-over for busy messages
handles.popup = uicontrol('parent',handles.main_fig,'units','normalized','Position',[0 0 1 1],'Style', 'text', 'String', {'','','','','','','','Embedding...'},'FontSize',36,'FontWeight','normal','Visible','off','BackgroundColor',[1 1 1]);


self.handles = handles;