%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% method that is called to load files 


function loadFile(self,src,~)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% reset some pushbuttons and other things
disp('need to clear current data')
% self.clearCurrentData;

% figure out what file types we can work with
allowed_file_extensions = setdiff(unique({self.installed_plugins.data_extension}),'n/a');
allowed_file_extensions = cellfun(@(x) ['*.' x], allowed_file_extensions,'UniformOutput',false);


if strcmp(get(src,'String'),'Load File')
    [self.file_name,self.path_name,filter_index] = uigetfile(allowed_file_extensions);
    if ~self.file_name
        return
    end
elseif strcmp(get(src,'String'),'<')
    if isempty(self.file_name)
        return
    else
        self.saveData;

        self.this_trial = [];
        self.this_paradigm = [];
        
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
else
    if isempty(self.file_name)
        return
    else
        self.saveData;

        self.this_trial = [];
        self.this_paradigm = [];

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
end

% OK, user has made some selection. let's figure out which plugin to use to load the data
chosen_data_ext = strrep(allowed_file_extensions{filter_index},'*.','');
plugin_to_use = find(strcmp('load-file',{self.installed_plugins.plugin_type}).*(strcmp(chosen_data_ext,{self.installed_plugins.data_extension})));
assert(~isempty(plugin_to_use),'[ERR 40] Could not figure out how to load the file you chose.')
assert(length(plugin_to_use) == 1,'[ERR 41] Too many plugins bound to this file type. ')

% load the file
load_file_handle = str2func(self.installed_plugins(plugin_to_use).name);
load_file_handle(self);

% update the titlebar with the name of the file we are working with
self.handles.main_fig.Name = self.file_name;


% check if there is a .crabsort file already
file_name = joinPath(self.path_name, [self.file_name '.crabsort']);

if exist(file_name,'file') == 2
    disp('file exists -- need to load it and update tghe object')
    load(file_name,'spikes','data_channel_names','-mat')
    self.data_channel_names = data_channel_names;
    self.spikes = spikes;

    % update data_channel_names
    for i = 1:length(self.data_channel_names)
        if ~isempty(self.data_channel_names{i})
            idx = find(strcmp(self.data_channel_names{i},self.channel_names));
            self.handles.channel_label_chooser(i).Value = idx;

            if strcmp(self.data_channel_names{i},'temperature')
                self.handles.ax(i).YLim = [0 30];

            end

        end
    end
end

% % enable all controls
% set(s.handles.method_control,'Enable','on')
% set(s.handles.sine_control,'Enable','on');
% set(s.handles.autosort_control,'Enable','on');
% set(s.handles.redo_control,'Enable','on');
% set(s.handles.filtermode,'Enable','on');
% set(s.handles.cluster_control,'Enable','on');
% set(s.handles.trial_chooser,'Enable','on');
% set(s.handles.paradigm_chooser,'Enable','on');
% set(s.handles.discard_control,'Enable','on');
% set(s.handles.metadata_text_control,'Enable','on')


    
% % check to see if this file is tagged. 
% if ismac
%     clear es
%     es{1} = 'tag -l ';
%     es{2} = strcat(s.path_name,s.file_name);
%     [~,temp] = unix(strjoin(es));
%     temp = strrep(temp,[s.path_name s.file_name],'');
%     set(s.handles.tag_control,'String',strtrim(temp));
% end
