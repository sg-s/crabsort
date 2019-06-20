
% method that is called to load files 


function loadFile(self,src,~)


channel = self.channel_to_work_with;


% are we showing a full trace view?
full_trace_view = false;
if ~isempty(self.handles)
    if isfield(self.handles,'ax')
        if round(max([self.handles.ax.ax.XLim])) == round(self.raw_data_size(1)*self.dt)
            full_trace_view = true;
        end
    end
end

try

hard_load = false;

if nargin == 1
    src.String = '';
    src.Style = 'none';
    hard_load = true;
end

% figure out what file types we can work with
if isempty(self.installed_plugins)
    self = self.plugins;
end
allowed_file_extensions = setdiff(unique({self.installed_plugins.data_extension}),'n/a');
allowed_file_extensions = cellfun(@(x) ['*.' x], allowed_file_extensions,'UniformOutput',false);
allowed_file_extensions = allowed_file_extensions(:);



if nargin > 1
    self.saveData;
end

if strcmp(src.String,'Load File')


    % attempt to cancel all workers
    try
        cancel(self.workers)
    catch
    end

    hard_load = true;


    if self.verbosity > 5
        disp('[loadFile] load_file_button is src')
    end

    cancel(self.workers)

    

    % reorder allowed_file_extensions
    try
        last_ext = getpref('crabsort','last_ext');
        exists_in_list = find(strcmp(allowed_file_extensions,last_ext));
        if ~isempty(exists_in_list)
            exists_in_list = exists_in_list(1);
            allowed_file_extensions(exists_in_list) = [];
            allowed_file_extensions = [last_ext ;allowed_file_extensions];
        end
    catch
    end

    [file_name,path_name,filter_index] = uigetfile(allowed_file_extensions);

    if ~file_name
        return
    else
        self.file_name = file_name;
        self.path_name = path_name;
    end

    if ~filelib.isWriteable(self.path_name)
        warndlg('The file you are loading is in a read-only directory. You will not be able to sort spikes here','crabsort')
    end

    % check to make sure all .ABF files have the same structure
    if strcmpi(self.file_name(end-2:end),'ABF') && ~self.pref.skip_abf_check
        self.checkABFFiles;
    end

    % make a note of the file format chosen
    setpref('crabsort','last_ext',allowed_file_extensions{filter_index})

    % convert the load file button to a file picker
    src.Style = 'popupmenu';
    allfiles = dir([self.path_name filesep allowed_file_extensions{filter_index}]);
    src.String = {allfiles.name};

elseif strcmp(src.Style,'popupmenu')


    % jump to file
    self.file_name = src.String{src.Value};

    [~,~,ext]=fileparts(self.file_name);
    filter_index = find(strcmp(['*' ext],allowed_file_extensions));

elseif strcmp(src.String,'<')

    if self.verbosity > 5
        disp('[loadFile] < is src]')
    end

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
        disp('[loadFile] > is src')
    end

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


    % do nothing, assuming that file_name is correctly set
    [~,~,ext] = fileparts(self.file_name);
    filter_index = find(strcmp(['*' ext],allowed_file_extensions));
end

self.reset(false);
if self.automate_action == crabsort.automateAction.none
    self.displayStatus('Loading...',true);
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
catch 

    warning('Error opening file')
    disp(self.file_name)
    if ~isempty(self.handles)
        self.handles.popup.Visible = 'off';

        uxlib.enable(self.handles.data_panel);
        uxlib.enable(self.handles.spike_detection_panel);
        uxlib.enable(self.handles.dim_red_panel);
        uxlib.enable(self.handles.cluster_panel);
        uxlib.disable(self.handles.manual_panel);

        self.handles.main_fig.Name = 'ERROR OPENING FILE';

    end

    return
end


% store the size of the raw_data
self.raw_data_size = size(self.raw_data);


if hard_load
    % reset common
    self.common = crabsort.common(self.n_channels);
    self.training_on = NaN(self.n_channels,1);
end



% set the channel_stages
self.channel_stage = zeros(self.n_channels,1);
self.channel_ylims = zeros(self.n_channels,1);

% reset ignore section
self.ignore_section = [];

% check if there is a .crabsort file already
file_name = pathlib.join(self.path_name, [self.file_name '.crabsort']);



if exist(file_name,'file') == 2


    load(file_name,'crabsort_obj','-mat')
    
    % copy over properties from crabsort_obj into self
    fn = fieldnames(crabsort_obj);
    for i = 1:length(fn)

        if any(strcmp(self.unsaved_variables,fn{i}))
            continue
        end

        if ~isempty(crabsort_obj.(fn{i}))
            self.(fn{i}) = crabsort_obj.(fn{i});
        end
    end

end

if hard_load

    % check that there is a crabsort.common file already
    file_name = pathlib.join(self.path_name, 'crabsort.common');

    if exist(file_name,'file') == 2
        if self.verbosity > 5
            disp('[loadFile] crabsort.common exists.')
        end

        load(file_name,'common','-mat');
        self.common = common;
    else
        if self.verbosity > 5
            disp('[loadFile] No crabsort.common!')
        end
    end


    % make sure we have computed the delays
    if ~isempty(self.handles)
        self.estimateDelay;
    end

end


% reconstruct the mask from ignore_section
self.reconstructMaskFromIgnoreSection;

for i = 1:self.raw_data_size(2)
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

uxlib.enable(self.handles.data_panel);
uxlib.show(self.handles.data_panel);
uxlib.enable(self.handles.spike_detection_panel);
uxlib.enable(self.handles.dim_red_panel);
uxlib.enable(self.handles.cluster_panel);
uxlib.disable(self.handles.manual_panel);

% update the channels menu to indicate the channels
% first nuke all the old names


if hard_load


    

    delete(self.handles.menu_name(6).Children)

    % do we already have some preference for which channels to hide?

    for i = 1:self.n_channels

        if self.common.show_hide_channels(i) 
            V = 'on';
        else
            V = 'off';
        end
        uimenu(self.handles.menu_name(6),'Label',self.builtin_channel_names{i},'Callback',@self.showHideChannels,'Checked',V);

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

end


% show the data

for i = 1:self.n_channels
    a = find(self.time >= self.handles.ax.data(i).XData(1),1,'first');
    z = find(self.time <= self.handles.ax.data(i).XData(end),1,'last');
    self.handles.ax.data(i).YData = self.raw_data(a:z,i);
end


% try to rescale the temperature channel correctly

for i = 1:self.n_channels
    if strcmp(self.common.data_channel_names{i},'temperature')
        self.handles.ax.ax(i).YLim = [5 35];
        self.handles.ax.ax(i).YTickMode = 'auto';
    end
end

if hard_load


    % check if we have the scales set 
    if any(isnan(self.common.y_scales))
        disp('Computing y_scales...')
        for i = 1:self.n_channels
            self.common.y_scales(i) = prctile(abs(self.raw_data(:,i)),99);
        end
    end

end



% reset all uncertain spikes
for i = 1:length(self.handles.ax.uncertain_spikes)
    self.handles.ax.uncertain_spikes(i).XData = NaN;
    self.handles.ax.uncertain_spikes(i).YData = NaN;
end


self.channel_to_work_with = channel;

% should we attempt to maintain the full-trace view?
if full_trace_view
    self.showFullTrace;
end

self.showSpikes;


catch err

    opts.WindowStyle = 'modal'; opts.Interpreter = 'tex';
    errordlg('\fontsize{20} Something went wrong in trying to load the data file. crabsort is now in debug mode. You must exit from debug mode before continuting. ','crabsort::LoadFile FATAL ERROR',opts)

    keyboard

    self.raw_data = [];
    self.displayStatus(err, true)
    save([hashlib.md5hash(now) '.error'],'err')


end

