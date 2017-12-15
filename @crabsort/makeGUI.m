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
uimenu(handles.menu0,'Label','Load file...','Callback',@s.loadFile);

% make a scrollbar at the bottom to quickly scroll
% through the traces

handles.scroll_bar = uicontrol(handles.main_fig,'units','normalized','Position',[.1 0 .89 .02],'Style', 'slider','callback',@self.scroll,'Visible','off');

addlistener(handles.scroll_bar,'ContinuousValueChange',@self.scroll);


handles.menu1 = uimenu('Label','Make Plots...');
uimenu(handles.menu1,'Label','Stimulus','Callback',@s.plot);
uimenu(handles.menu1,'Label','LFP','Callback',@s.plot);
uimenu(handles.menu1,'Label','Raster','Callback',@s.plot);
uimenu(handles.menu1,'Label','Firing Rate','Callback',@s.plot);

% pre-processing
handles.menu2 = uimenu('Label','Tools');
% uimenu(handles.menu2,'Label','Template Match','Callback',@s.matchTemplate);
% handles.remove_artifacts_menu = uimenu(handles.menu2,'Label','Remove Artifacts','Callback',@removeArtifacts,'Checked',s.pref.remove_artifacts);
% uimenu(handles.menu2,'Label','Reload preferences','Callback',@s.reloadPreferences,'Separator','on');
% uimenu(handles.menu2,'Label','Reset zoom','Callback',@s.resetZoom);
% delete(temp([1:8 11:15]))

% % make the two axes
% handles.ax1 = axes('parent',handles.main_fig,'Position',[0.07 0.05 0.87 0.29]); hold on
% handles.jump_back = uicontrol(handles.main_fig,'units','normalized','Position',[0 .04 .04 .50],'Style', 'pushbutton', 'String', '<','callback',@s.jump);
% handles.jump_fwd = uicontrol(handles.main_fig,'units','normalized','Position',[.96 .04 .04 .50],'Style', 'pushbutton', 'String', '>','callback',@s.jump);
% handles.ax2 = axes('parent',handles.main_fig,'Position',[0.07 0.37 0.87 0.18]); hold on
% linkaxes([handles.ax2,handles.ax1],'x')

% % make dummy plots on these axes, for placeholders later on
% handles.ax1_data = plot(handles.ax1,NaN,NaN);
% handles.ax1_spike_marker = plot(handles.ax1,NaN,NaN);
% handles.ax1_A_spikes = plot(handles.ax1,NaN,NaN);
% handles.ax1_B_spikes = plot(handles.ax1,NaN,NaN);
% handles.ax1_all_spikes = plot(handles.ax1,NaN,NaN);
% handles.ax1_ignored_data = plot(handles.ax1,NaN,NaN);

% % now some for ax1
% handles.ax2_data = plot(handles.ax2,NaN,NaN);
% for si = 1:10
%     handles.ax2_control_signals(si) = plot(handles.ax2,NaN,NaN);
% end


% % make all the panels

% % datapanel (allows you to choose what to plot where)
% handles.datapanel = uipanel('Title','Data','Position',[.85 .57 .14 .4],'BackgroundColor',[1 1 1]);
% uicontrol(handles.datapanel,'units','normalized','Position',[.02 .9 .510 .10],'Style', 'text', 'String', 'Control Signal','FontSize',s.pref.fs,'FontWeight',s.pref.fw);
% handles.valve_channel = uicontrol(handles.datapanel,'units','normalized','Position',[.03 .68 .910 .25],'Style', 'listbox', 'String', '','FontSize',s.pref.fs,'FontWeight',s.pref.fw,'Callback',@plotValve,'Min',0,'Max',2);
% uicontrol(handles.datapanel,'units','normalized','Position',[.01 .56 .510 .10],'Style', 'text', 'String', 'Stimulus','FontSize',s.pref.fs,'FontWeight',s.pref.fw);
% handles.stim_channel = uicontrol(handles.datapanel,'units','normalized','Position',[.03 .38 .910 .20],'Style', 'listbox', 'String', '','FontSize',s.pref.fs,'FontWeight',s.pref.fw,'Callback',@s.plotStim);

% uicontrol(handles.datapanel,'units','normalized','Position',[.01 .25 .610 .10],'Style', 'text', 'String', 'Response','FontSize',s.pref.fs,'FontWeight',s.pref.fw);
% handles.resp_channel = uicontrol(handles.datapanel,'units','normalized','Position',[.01 .01 .910 .25],'Style', 'listbox', 'String', '','FontSize',s.pref.fs,'FontWeight',s.pref.fw);


% file I/O
uicontrol(handles.main_fig,'units','normalized','Position',[.10 .92 .09 .07],'Style', 'pushbutton', 'String', 'Load File','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile);
uicontrol(handles.main_fig,'units','normalized','Position',[.05 .93 .03 .05],'Style', 'pushbutton', 'String', '<','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile);
uicontrol(handles.main_fig,'units','normalized','Position',[.21 .93 .03 .05],'Style', 'pushbutton', 'String', '>','FontSize',self.pref.fs,'FontWeight',self.pref.fw,'callback',@self.loadFile);

% % paradigms and trials
% handles.datachooserpanel = uipanel('Title','Paradigms and Trials','Position',[.03 .75 .25 .16],'BackgroundColor',[1 1 1]);
% handles.paradigm_chooser = uicontrol(handles.datachooserpanel,'units','normalized','Position',[.25 .75 .5 .20],'Style', 'popupmenu', 'String', 'Choose Paradigm','callback',@s.updateTrialsParadigms,'Enable','off');
% handles.next_paradigm = uicontrol(handles.datachooserpanel,'units','normalized','Position',[.75 .65 .15 .33],'Style', 'pushbutton', 'String', '>','callback',@s.updateTrialsParadigms,'Enable','off');
% handles.prev_paradigm = uicontrol(handles.datachooserpanel,'units','normalized','Position',[.05 .65 .15 .33],'Style', 'pushbutton', 'String', '<','callback',@s.updateTrialsParadigms,'Enable','off');

% handles.trial_chooser = uicontrol(handles.datachooserpanel,'units','normalized','Position',[.25 .27 .5 .20],'Style', 'popupmenu', 'String', 'Choose Trial','callback',@s.updateTrialsParadigms,'Enable','off');
% handles.next_trial = uicontrol(handles.datachooserpanel,'units','normalized','Position',[.75 .15 .15 .33],'Style', 'pushbutton', 'String', '>','callback',@s.updateTrialsParadigms,'Enable','off');
% handles.prev_trial = uicontrol(handles.datachooserpanel,'units','normalized','Position',[.05 .15 .15 .33],'Style', 'pushbutton', 'String', '<','callback',@s.updateTrialsParadigms,'Enable','off');


% % spike detection panel
% handles.spike_detection_panel = uipanel('Title','Spike detection','Position',[.3 .77 .3 .2],'BackgroundColor',[1 1 1]);
% uicontrol(handles.spike_detection_panel,'units','normalized','Position',[0 .88 .5 .1],'Style','text','String','Peak Prominence:','FontSize',s.pref.fs,'FontWeight','normal','BackgroundColor','w')
% handles.prom_auto_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.5 .8 .3 .2],'Style','togglebutton','String','MANUAL','Value',0,'FontSize',s.pref.fs,'Callback',@s.togglePromControl);
% handles.prom_ub_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.73 .65 .2 .15],'Style','edit','String','1','FontSize',s.pref.fs,'Callback',@s.updateSpikePromSlider);
% handles.spike_prom_slider = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.01 .63 .7 .15],'Style','Slider','Min',0,'Max',1,'Value',.5,'Callback',@s.findSpikes);
% try    % R2013b and older
%    addlistener(handles.spike_prom_slider,'ActionEvent',@s.findSpikes);
% catch  % R2014a and newer
%    addlistener(handles.spike_prom_slider,'ContinuousValueChange',@s.findSpikes);
% end
% if s.pref.invert_V
%     handles.spike_sign_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.01 .4 .5 .2],'Style','togglebutton','String','Finding -ve spikes','Value',0,'FontSize',s.pref.fs,'Callback',@s.toggleSpikeSign);
% else
%     handles.spike_sign_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.01 .4 .5 .2],'Style','togglebutton','String','Finding +ve spikes','Value',1,'FontSize',s.pref.fs,'Callback',@s.toggleSpikeSign);
% end

% handles.kill_ringing_control = uicontrol(handles.spike_detection_panel,'units','normalized','Position',[.5 .4 .5 .2],'Style','pushbutton','String','Kill ringing','FontSize',s.pref.fs,'Callback',@s.killRinging,'Visible','on');

% % dimension reduction and clustering panels
% handles.dimredpanel = uipanel('Title','Dimensionality Reduction','Position',[.3 .67 .3 .07],'BackgroundColor',[1 1 1]);
% all_plugin_names = {s.installed_plugins.name};
% dim_red_plugins = all_plugin_names(find(strcmp({s.installed_plugins.plugin_type},'dim-red')));

% handles.method_control = uicontrol(handles.dimredpanel,'Style','popupmenu','String',dim_red_plugins,'units','normalized','Position',[.02 .6 .9 .2],'Callback',@s.reduceDimensionsCallback,'Enable','off','FontSize',20);

% % find the available methods for clustering
% all_plugin_names = {s.installed_plugins.name};
% cluster_plugins = all_plugin_names(find(strcmp({s.installed_plugins.plugin_type},'cluster')));

% handles.cluster_panel = uipanel('Title','Clustering','Position',[.30 .57 .3 .07],'BackgroundColor',[1 1 1]);
% handles.cluster_control = uicontrol(handles.cluster_panel,'Style','popupmenu','String',cluster_plugins,'units','normalized','Position',[.02 .6 .9 .2],'Callback',@s.clusterCallback,'Enable','off','FontSize',20);


% % metadata panel
% handles.metadata_panel = uipanel('Title','Metadata','Position',[.62 .57 .11 .4],'BackgroundColor',[1 1 1]);
% handles.metadata_text_control = uicontrol(handles.metadata_panel,'Style','edit','String','','units','normalized','Position',[.03 .3 .94 .7],'Callback',@s.updateMetadata,'Enable','off','Max',5,'Min',1,'HorizontalAlignment','left');
% uicontrol(handles.metadata_panel,'Style','pushbutton','String','Generate Summary','units','normalized','Position',[.03 .035 .94 .1],'Callback',@s.generateSummary,'Enable','off');

% % manual override panel
% handles.manualpanel = uibuttongroup(handles.main_fig,'Title','Manual Override','Position',[.735 .57 .11 .4]);
% uicontrol(handles.manualpanel,'units','normalized','Position',[.1 7/8 .8 1/9],'Style','pushbutton','String','Mark All in View','Callback',@s.markAllCallback);
% handles.mode_new_A = uicontrol(handles.manualpanel,'units','normalized','Position',[.1 6/8 .8 1/9], 'Style', 'radiobutton', 'String', '+A','FontSize',s.pref.fs);
% handles.mode_new_B = uicontrol(handles.manualpanel,'units','normalized','Position',[.1 5/8 .8 1/9], 'Style', 'radiobutton', 'String', '+B','FontSize',s.pref.fs);
% handles.mode_delete = uicontrol(handles.manualpanel,'units','normalized','Position',[.1 4/8 .8 1/9], 'Style', 'radiobutton', 'String', '-X','FontSize',s.pref.fs);
% handles.mode_A2B = uicontrol(handles.manualpanel,'units','normalized','Position',[.1 3/8 .8 1/9], 'Style', 'radiobutton', 'String', 'A->B','FontSize',s.pref.fs);
% handles.mode_B2A = uicontrol(handles.manualpanel,'units','normalized','Position',[.1 2/8 .8 1/9], 'Style', 'radiobutton', 'String', 'B->A','FontSize',s.pref.fs);
% uicontrol(handles.manualpanel,'units','normalized','Position',[.1 1/8 .8 1/9],'Style','pushbutton','String','Discard View','Callback',@s.modifyTraceDiscard,'Enable','off');
% uicontrol(handles.manualpanel,'units','normalized','Position',[.1 0/8 .8 1/9],'Style','pushbutton','String','Retain View','Callback',@s.modifyTraceDiscard,'Enable','off');


% % various toggle switches and pushbuttons
% handles.filtermode = uicontrol(handles.main_fig,'units','normalized','Position',[.03 .69 .12 .05],'Style','togglebutton','String','Filter','Value',s.filter_trace,'Callback',@s.toggleFilter,'Enable','off');
% if s.filter_trace
%     set(handles.filtermode,'String','Filter is ON')
% else
%     set(handles.filtermode,'String','Filter is ON')
% end

% handles.redo_control = uicontrol(handles.main_fig,'units','normalized','Position',[.03 .64 .12 .05],'Style','pushbutton','String','Redo','Value',0,'Callback',@s.redo,'Enable','off');
% handles.autosort_control = uicontrol(handles.main_fig,'units','normalized','Position',[.16 .64 .12 .05],'Style','togglebutton','String','Autosort','Value',0,'Enable','off','Callback',@autosortCallback);

% handles.sine_control = uicontrol(handles.main_fig,'units','normalized','Position',[.03 .59 .12 .05],'Style','togglebutton','String',' Kill Ringing','Value',0,'Callback',@s.plotResp,'Enable','off');
% handles.discard_control = uicontrol(handles.main_fig,'units','normalized','Position',[.16 .59 .12 .05],'Style','togglebutton','String',' Discard','Value',0,'Callback',@s.discard,'Enable','off');


% % disable tagging on non unix systems
% if ispc
% else
%     handles.tag_control = uicontrol(handles.metadata_panel,'Style','edit','String','+Tag, or -Tag','units','normalized','Position',[.03 .15 .9 .1],'Callback',@s.addTag);

%     % modify environment to get paths for non-matlab code right
%     if ~ismac
%         path1 = getenv('PATH');
%         if isempty(strfind(path1,[pathsep '/usr/local/bin']))
%             path1 = [path1 pathsep '/usr/local/bin'];
%         end

%         setenv('PATH', path1);
%     end

% end

% % make a pop-over for busy messages
% handles.popup = uicontrol('parent',handles.main_fig,'units','normalized','Position',[0 .57 1 .46],'Style', 'text', 'String', {'','','','Embedding...'},'FontSize',24,'FontWeight','normal','Visible','off');


self.handles = handles;