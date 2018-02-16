%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% makes the tensorflow GUI

function makeTensorFlowGUI(self,~,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

self.saveData;

self.handles.tf.fig = figure('Units','normalized','position',[0.2 0.2 .4 .5], 'Toolbar','figure','Menubar','none','Name','crabsort::Tensorflow','NumberTitle','off','IntegerHandle','off','Color','w');

S = ['Choose channel with spikes...'; vectorise(self.common.data_channel_names(~(cellfun(@isempty,self.common.data_channel_names))))];
self.handles.tf.channel_picker = uicontrol(self.handles.tf.fig,'Style','popupmenu','String',S,'units','normalized','Position',[.01 .85 .3 .11],'Callback',@self.updateTFChannel,'FontSize',self.pref.fs*1.2);

this_channel = self.handles.tf.channel_picker.String{self.handles.tf.channel_picker.Value};
S = self.getFilesWithSortedSpikesOnChannel(this_channel);

self.handles.tf.available_data = uicontrol(self.handles.tf.fig,'Style','listbox','String',S,'units','normalized','Position',[.01 .6 .3 .3],'FontSize',self.pref.fs,'Min',0,'Max',2,'Enable','off');

self.handles.tf.load_data = uicontrol(self.handles.tf.fig,'Style','pushbutton','String','Load Data','units','normalized','Position',[.01 .51 .1 .07],'FontSize',self.pref.fs,'Callback',@self.loadTFData,'Enable','off');

self.handles.tf.unload_data = uicontrol(self.handles.tf.fig,'Style','pushbutton','String','Unload Data','units','normalized','Position',[.15 .51 .1 .07],'FontSize',self.pref.fs,'Callback',@self.unloadTFData,'Enable','off');

% make the axes
self.handles.tf.pca_ax = axes(self.handles.tf.fig,'Units','normalized','Position',[.4 .4 .58 .56]);
hold(self.handles.tf.pca_ax,'on')
self.handles.tf.pca_ax.Box = 'on';
M = {'o','d','p','h','s'};
opacity = .3;
for i = 1:length(M)
	self.handles.tf.pca_plot(i) = scatter(self.handles.tf.pca_ax,NaN,NaN,128,[.5 .5 .5],'filled','Marker',M{i},'MarkerFaceAlpha',opacity,'MarkerEdgeAlpha',opacity);
end

self.handles.tf.pca_ax.XTick = [];
self.handles.tf.pca_ax.YTick = [];

self.handles.tf.accuracy_ax = axes(self.handles.tf.fig,'Units','normalized','Position',[.4 .1 .58 .2]);
hold(self.handles.tf.accuracy_ax,'on')
xlabel(self.handles.tf.accuracy_ax,'nsteps')
ylabel(self.handles.tf.accuracy_ax,'1 - Accuracy')
self.handles.tf.accuracy_ax.YScale = 'log';
self.handles.tf.accuracy_ax.YLim = [1e-3 1];
self.handles.tf.accuracy_ax.XLim = [0 1e3];
self.handles.tf.accuracy_ax.YTick = [1e-3 1e-2 1e-1 1];
self.handles.tf.accuracy_ax.YGrid = 'on';
self.handles.tf.accuracy_plot = plot(self.handles.tf.accuracy_ax,NaN,NaN,'ko-','LineWidth',2);


self.handles.tf.train_button = uicontrol(self.handles.tf.fig,'Style','togglebutton','String','TRAIN','units','normalized','Position',[.01 .31 .15 .1],'FontSize',self.pref.fs,'Callback',@self.train,'Enable','off');

self.handles.tf.reset_network_button = uicontrol(self.handles.tf.fig,'Style','togglebutton','String','Reset network','units','normalized','Position',[.01 .01 .2 .07],'FontSize',self.pref.fs,'Callback',@self.reset_network,'Enable','off');

prettyFig;