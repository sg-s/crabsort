%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% method that is called to load files 


function loadFile(self,src,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


if nargin == 1
    src.String = '';
end

% figure out what file types we can work with
allowed_file_extensions = setdiff(unique({self.installed_plugins.data_extension}),'n/a');
allowed_file_extensions = cellfun(@(x) ['*.' x], allowed_file_extensions,'UniformOutput',false);
allowed_file_extensions = allowed_file_extensions(:);


% attempt to cancel all workers
try
    cancel(self.workers)
catch
end


if strcmp(src.String,'Load File')

    if self.verbosity > 5
        disp(['[loadFile] load_file_button is src'])
    end


    self.saveData;
    try
        [file_name,path_name,filter_index] = uigetfile(allowed_file_extensions);
    catch err
        for ei = 1:length(err)
                        err.stack(ei)
                    end
    end
    if ~file_name
        return
    else
        self.file_name = file_name;
        self.path_name = path_name;
    end

    % check to make sure all .ABF files have the same structure
    if strcmpi(self.file_name(end-2:end),'ABF') && ~self.pref.skip_abf_check
        self.checkABFFiles;
    end

    

elseif strcmp(src.String,'<')

    if self.verbosity > 5
        disp(['[loadFile] < is src]'])
    end

    self.saveData;
    if isempty(self.file_name)
        return
    else

        % get the list of files
        [~,~,ext]=fileparts(self.file_name);
        allfiles = dir([self.path_name '*' ext]);
        % remove hidden files that begin with a ".
        allfiles(cellfun(@(x) strcmp(x(1),'.'),{allfiles.name})) = [];
        % permute the list so that the current file is last
        allfiles = circshift({allfiles.name},[0,length(allfiles)-find(strcmp(self.file_name,{allfiles.name}))])';
        % pick the previous one 
        self.file_name = allfiles{end-1};
        % figure out what the filter_index is
        filter_index = find(strcmp(['*' ext],allowed_file_extensions));
        
    
    end
elseif strcmp(src.String,'>')

    if self.verbosity > 5
        disp(['[loadFile] > is src'])
    end

    self.saveData;
    if isempty(self.file_name)
        return
    else


        % get the list of files
        [~,~,ext]=fileparts(self.file_name);
        allfiles = dir([self.path_name '*' ext]);
        % remove hidden files that begin with a ".
        allfiles(cellfun(@(x) strcmp(x(1),'.'),{allfiles.name})) = [];
        % permute the list so that the current file is last
        allfiles = circshift({allfiles.name},[0,length(allfiles)-find(strcmp(self.file_name,{allfiles.name}))])';
        % pick the first one 
        self.file_name = allfiles{1};
        % figure out what the filter_index is
        filter_index = find(strcmp(['*' ext],allowed_file_extensions));
        

    end
else

    if self.verbosity > 5
        disp(['[loadFile] no src.'])
    end

    % do nothing, assuming that file_name is correctly set
    [~,~,ext] = fileparts(self.file_name);
    filter_index = find(strcmp(['*' ext],allowed_file_extensions));
end

if self.verbosity > 5
    disp(['[loadFile] calling reset'])
end

self.reset(false);

if ~isempty(self.handles)
    uistack(self.handles.popup,'top')
    self.handles.popup.Visible = 'on';
    self.handles.popup.String = {'','','','','','','','Loading file...'};
    drawnow;
end


% OK, user has made some selection. let's figure out which plugin to use to load the data
chosen_data_ext = strrep(allowed_file_extensions{filter_index},'*.','');
plugin_to_use = find(strcmp('load-file',{self.installed_plugins.plugin_type}).*(strcmp(chosen_data_ext,{self.installed_plugins.data_extension})));
assert(~isempty(plugin_to_use),'[ERR 40] Could not figure out how to load the file you chose.')
assert(length(plugin_to_use) == 1,'[ERR 41] Too many plugins bound to this file type. ')


% load the file
load_file_handle = str2func(self.installed_plugins(plugin_to_use).name);

self.builtin_channel_names = {};

try
    load_file_handle(self);
catch err
    for ei = 1:length(err)
        err.stack(ei)
    end
    warning('Error opening file')
    disp(self.file_name)
    if ~isempty(self.handles)
        self.handles.popup.Visible = 'off';

        enable(self.handles.data_panel);
        enable(self.handles.spike_detection_panel);
        enable(self.handles.dim_red_panel);
        enable(self.handles.cluster_panel);
        disable(self.handles.manual_panel);

        self.handles.main_fig.Name = 'ERROR OPENING FILE';

    end

    return
end

% reset common
self.common = [];


% set the channel_stages
self.channel_stage = zeros(size(self.raw_data,2),1);
self.channel_ylims = zeros(size(self.raw_data,2),1);

% make placeholders for data_channel_names
self.common.data_channel_names = cell(self.n_channels,1);

% check if there is a .crabsort file already
file_name = joinPath(self.path_name, [self.file_name '.crabsort']);



if exist(file_name,'file') == 2

    if self.verbosity > 5
        disp('[loadFile] .crabsort  file exists. Loading...');
    end

    load(file_name,'crabsort_obj','-mat')
    
    % copy over properties from crabsort_obj into self
    fn = fieldnames(crabsort_obj);
    for i = 1:length(fn)
        if ~isempty(crabsort_obj.(fn{i}))
            % ignore channel_names
            % this is a hack because channel_names was erroneously
            % saved in some .crabsort files
            if ~strcmp(fn{i},'channel_names')
                self.(fn{i}) = crabsort_obj.(fn{i});
            end
        end
    end

end


% check that there is a common.crabsort file already
file_name = joinPath(self.path_name, 'common.crabsort');

if exist(file_name,'file') == 2
    if self.verbosity > 5
        disp(['[loadFile] common.crabsort exists.'])
    end

    load(file_name,'common','-mat');
    self.common = common;
else
    if self.verbosity > 5
        disp(['[loadFile] No common.crabsort!'])
    end
end

% make sure we have computed the delays
self.estimateDelay;


% populate fields in common 
req_fields = {'data_channel_names','tf_model_name','tf_data','tf_labels','tf_folder','automate_info','automate_channel_order'};
for i = 1:length(req_fields)
    if ~isfield(self.common,req_fields{i})
        self.common.(req_fields{i}) = [];
    end
end

if self.verbosity > 5
    disp(['[loadFile] remove mean for all channels that have names'])
end


for i = 1:length(self.common.data_channel_names)
    if isempty(self.common.data_channel_names{i})
        continue
    end

    if strcmp(self.common.data_channel_names{i},'temperature')
        continue
    end

    % check if channel is intracellular 
    temp = isstrprop(self.common.data_channel_names{i},'upper');
    if any(temp)
        continue
    end

    self.removeMean(i);
end



% make a putative_spikes matrix
self.putative_spikes = 0*self.raw_data;


% round the sampling time to the nearest microsecond
% this fixes bugs that arise from dt being slightly different
% and causing a different frame size when calling getSnippets
self.dt = round(self.dt*1e6)/1e6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              _                           _  __ _      
%   __ _ _   _(_)      ___ _ __   ___  ___(_)/ _(_) ___ 
%  / _` | | | | |_____/ __| '_ \ / _ \/ __| | |_| |/ __|
% | (_| | |_| | |_____\__ \ |_) |  __/ (__| |  _| | (__ 
%  \__, |\__,_|_|     |___/ .__/ \___|\___|_|_| |_|\___|
%  |___/                  |_|                           
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(self.handles)
    return
end

self.handles.main_fig.Name = self.file_name;

self.handles.popup.Visible = 'off';

enable(self.handles.data_panel);
enable(self.handles.spike_detection_panel);
enable(self.handles.dim_red_panel);
enable(self.handles.cluster_panel);
disable(self.handles.manual_panel);

% update the channels menu to indicate the channels
% first nuke all the old names

delete(self.handles.menu_name(5).Children)

% do we already have some preference for which channels to hide?
try
    show_hide_channels = self.common.show_hide_channels;
catch err
    for ei = 1:length(err)
        err.stack(ei)
    end
    self.common.show_hide_channels = true(self.n_channels,1);
end

for i = 1:self.n_channels

    if self.common.show_hide_channels(i) 
        V = 'on';
    else
        V = 'off';
    end
    uimenu(self.handles.menu_name(5),'Label',self.builtin_channel_names{i},'Callback',@self.showHideChannels,'Checked',V);

end

self.redrawAxes;

% force an update of built-in channel names
for i = 1:self.n_channels
	self.handles.ax.channel_names(i).String = self.builtin_channel_names{i};
	if isempty(self.common.data_channel_names{i})
		self.handles.ax.channel_label_chooser(i).Value = 1;
	else
		self.handles.ax.channel_label_chooser(i).Value = find(strcmp(self.common.data_channel_names{i},self.handles.ax.channel_label_chooser(i).String));
	end
end

self.showSpikes;

% show the data

for i = 1:self.n_channels
    a = find(self.time >= self.handles.ax.data(i).XData(1),1,'first');
    z = find(self.time <= self.handles.ax.data(i).XData(end),1,'last');
    self.handles.ax.data(i).YData = self.raw_data(a:z,i);
end


% try to rescale the temperature channel correctly
try
    for i = 1:self.n_channels
        if strcmp(self.common.data_channel_names{i},'temperature')
            self.handles.ax.ax(i).YLim = [5 35];
            self.handles.ax.ax(i).YTickMode = 'auto';
        end
    end
catch err
    for ei = 1:length(err)
        err.stack(ei)
    end
end


% logging for debugging 
try
    if ~isempty(self.file_name)
        debuglog('crabsort',self.file_name)
    end
catch
end



% check if we have the scales set 
if ~isfield(self.common,'y_scales')
    disp('Computing y_scales...')
    for i = 1:self.n_channels
        self.common.y_scales(i) = prctile(abs(self.raw_data(:,i)),99);
    end
end

self.handles.nn_panel.Visible = 'on';