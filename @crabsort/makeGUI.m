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

% make plots menu
handles.menu0 = uimenu('Label','Data');
uimenu(handles.menu0,'Label','Load file...','Callback',@self.loadFile);

% make a scrollbar at the bottom to quickly scroll
% through the traces

handles.scroll_bar = uicontrol(handles.main_fig,'units','normalized','Position',[.1 0 .89 .02],'Style', 'slider','callback',@self.scroll,'Visible','off');

addlistener(handles.scroll_bar,'ContinuousValueChange',@self.scroll);


handles.menu1 = uimenu('Label','Make Plots...');
uimenu(handles.menu1,'Label','Stimulus','Callback',@self.plot);
uimenu(handles.menu1,'Label','LFP','Callback',@self.plot);
uimenu(handles.menu1,'Label','Raster','Callback',@self.makeRaster);
uimenu(handles.menu1,'Label','Firing Rate','Callback',@self.plot);

% pre-processing
handles.menu2 = uimenu('Label','Tools');
% uimenu(handles.menu2,'Label','Template Match','Callback',@self.matchTemplate);
% handles.remove_artifacts_menu = uimenu(handles.menu2,'Label','Remove Artifacts','Callback',@removeArtifacts,'Checked',self.pref.remove_artifacts);
% uimenu(handles.menu2,'Label','Reload preferences','Callback',@self.reloadPreferences,'Separator','on');
% uimenu(handles.menu2,'Label','Reset zoom','Callback',@self.resetZoom);
% delete(temp([1:8 11:15]))



% % make all the panels

% % datapanel (allows you to choose what to plot where)
% handles.datapanel = uipanel('Title','Data','Position',[.85 .57 .14 .4],'BackgroundColor',[1 1 1]);
% uicontrol(handles.datapanel,'units','normalized','Position',[.02 .9 .510 .10],'Style', 'text', 'String', 'Control Signal','FontSize',self.pref.fs,'FontWeight',self.pref.fw);
% handles.valve_channel = uicontrol(handles.datapanel,'units','normalized','Position',[.03 .68 .910 .25],'Style', 'listbox', 'String', '','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'Callback',@plotValve,'Min',0,'Max',2);
% uicontrol(handles.datapanel,'units','normalized','Position',[.01 .56 .510 .10],'Style', 'text', 'String', 'Stimulus','FontSize',self.pref.fs,'FontWeight',self.pref.fw);
% handles.stim_channel = uicontrol(handles.datapanel,'units','normalized','Position',[.03 .38 .910 .20],'Style', 'listbox', 'String', '','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'Callback',@self.plotStim);

% uicontrol(handles.datapanel,'units','normalized','Position',[.01 .25 .610 .10],'Style', 'text', 'String', 'Response','FontSize',self.pref.fs,'FontWeight',self.pref.fw);
% handles.resp_channel = uicontrol(handles.datapanel,'units','normalized','Position',[.01 .01 .910 .25],'Style', 'listbox', 'String', '','FontSize',self.pref.fs,'FontWeight',self.pref.fw);


% file I/O panel
handles.data_panel = uipanel('Title','Select Data file','Position',[.01 .92 .2 .07],'BackgroundColor',[1 1 1]);

uicontrol(handles.data_panel,'units','normalized','Position',[.05 .2 .15 .6],'Style', 'pushbutton', 'String', '<','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile);

uicontrol(handles.data_panel,'units','normalized','Position',[.2 .1 .6 .8],'Style', 'pushbutton', 'String', 'Load File','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile);

uicontrol(handles.data_panel,'units','normalized','Position',[.8 .2 .15 .6],'Style', 'pushbutton', 'String', '>','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile);


% spike detection panel
handles.spike_detection_panel = uipanel('Title','Spike detection','Position',[.22 .92 .2 .07],'BackgroundColor',[1 1 1]);

handles.prom_auto_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.5 .01 .4 .4],'Style','togglebutton','String','MANUAL','Value',0,'FontSize',self.pref.fs,'Callback',@self.togglePromControl,'Enable','off');
handles.prom_ub_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.85 .65 .1 .4],'Style','edit','String','1','FontSize',self.pref.fs,'Callback',@self.updateSpikePromSlider,'Enable','off');
handles.spike_prom_slider = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.01 .63 .8 .25],'Style','Slider','Min',0,'Max',1,'Value',.5,'Callback',@self.findSpikes,'Enable','off');
try    % R2013b and older
   addlistener(handles.spike_prom_slider,'ActionEvent',@self.findSpikes);
catch  % R2014a and newer
   addlistener(handles.spike_prom_slider,'ContinuousValueChange',@self.findSpikes);
end
if self.pref.invert_V
    handles.spike_sign_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.01 .01 .4 .4],'Style','togglebutton','String','Finding -ve spikes','Value',0,'FontSize',self.pref.fs,'Callback',@self.toggleSpikeSign,'Enable','off');
else
    handles.spike_sign_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.01 .01 .4 .4],'Style','togglebutton','String','Finding +ve spikes','Value',1,'FontSize',self.pref.fs,'Callback',@self.toggleSpikeSign,'Enable','off');
end


handles.dim_red_panel = uipanel('Title','Dimensionality reduction','Position',[.43 .92 .2 .07],'BackgroundColor',[1 1 1]);

all_plugin_names = {self.installed_plugins.name};
dim_red_plugins = all_plugin_names(find(strcmp({self.installed_plugins.plugin_type},'dim-red')));

handles.method_control = uicontrol(handles.dim_red_panel,'Style','popupmenu','String',dim_red_plugins,'units','normalized','Position',[.02 .6 .9 .2],'Callback',@self.reduceDimensionsCallback,'Enable','off','FontSize',20);



handles.cluster_panel = uipanel('Title','Cluster & Sort','Position',[.64 .92 .2 .07],'BackgroundColor',[1 1 1]);

% find the available methods for clustering
all_plugin_names = {self.installed_plugins.name};
cluster_plugins = all_plugin_names(find(strcmp({self.installed_plugins.plugin_type},'cluster')));

handles.cluster_control = uicontrol(handles.cluster_panel,'Style','popupmenu','String',cluster_plugins,'units','normalized','Position',[.02 .6 .9 .2],'Callback',@self.clusterCallback,'Enable','off','FontSize',20);


handles.redo_button = uicontrol(handles.main_fig,'units','normalized','Position',[.88 .93 .05 .04],'String','REDO','Style','pushbutton','Callback',@self.redo);

% % metadata panel
% handles.metadata_panel = uipanel('Title','Metadata','Position',[.62 .57 .11 .4],'BackgroundColor',[1 1 1]);
% handles.metadata_text_control = uicontrol(handles.metadata_panel,'Style','edit','String','','units','normalized','Position',[.03 .3 .94 .7],'Callback',@self.updateMetadata,'Enable','off','Max',5,'Min',1,'HorizontalAlignment','left');
% uicontrol(handles.metadata_panel,'Style','pushbutton','String','Generate Summary','units','normalized','Position',[.03 .035 .94 .1],'Callback',@self.generateSummary,'Enable','off');

% % manual override panel
% handles.manualpanel = uibuttongroup(handles.main_fig,'Title','Manual Override','Position',[.735 .57 .11 .4]);
% uicontrol(handles.manualpanel,'units','normalized','Position',[.1 7/8 .8 1/9],'Style','pushbutton','String','Mark All in View','Callback',@self.markAllCallback);
% handles.mode_new_A = uicontrol(handles.manualpanel,'units','normalized','Position',[.1 6/8 .8 1/9], 'Style', 'radiobutton', 'String', '+A','FontSize',self.pref.fs);
% handles.mode_new_B = uicontrol(handles.manualpanel,'units','normalized','Position',[.1 5/8 .8 1/9], 'Style', 'radiobutton', 'String', '+B','FontSize',self.pref.fs);
% handles.mode_delete = uicontrol(handles.manualpanel,'units','normalized','Position',[.1 4/8 .8 1/9], 'Style', 'radiobutton', 'String', '-X','FontSize',self.pref.fs);
% handles.mode_A2B = uicontrol(handles.manualpanel,'units','normalized','Position',[.1 3/8 .8 1/9], 'Style', 'radiobutton', 'String', 'A->B','FontSize',self.pref.fs);
% handles.mode_B2A = uicontrol(handles.manualpanel,'units','normalized','Position',[.1 2/8 .8 1/9], 'Style', 'radiobutton', 'String', 'B->A','FontSize',self.pref.fs);
% uicontrol(handles.manualpanel,'units','normalized','Position',[.1 1/8 .8 1/9],'Style','pushbutton','String','Discard View','Callback',@self.modifyTraceDiscard,'Enable','off');
% uicontrol(handles.manualpanel,'units','normalized','Position',[.1 0/8 .8 1/9],'Style','pushbutton','String','Retain View','Callback',@self.modifyTraceDiscard,'Enable','off');




% % disable tagging on non unix systems
% if ispc
% else
%     handles.tag_control = uicontrol(handles.metadata_panel,'Style','edit','String','+Tag, or -Tag','units','normalized','Position',[.03 .15 .9 .1],'Callback',@self.addTag);

%     % modify environment to get paths for non-matlab code right
%     if ~ismac
%         path1 = getenv('PATH');
%         if isempty(strfind(path1,[pathsep '/usr/local/bin']))
%             path1 = [path1 pathsep '/usr/local/bin'];
%         end

%         setenv('PATH', path1);
%     end

% end

% make a pop-over for busy messages
handles.popup = uicontrol('parent',handles.main_fig,'units','normalized','Position',[0 0 1 1],'Style', 'text', 'String', {'','','','Embedding...'},'FontSize',24,'FontWeight','normal','Visible','off');


self.handles = handles;