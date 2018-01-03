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

if nargin == 1
    src.String = '';
end

% figure out what file types we can work with
allowed_file_extensions = setdiff(unique({self.installed_plugins.data_extension}),'n/a');
allowed_file_extensions = cellfun(@(x) ['*.' x], allowed_file_extensions,'UniformOutput',false);


if strcmp(src.String,'Load File')
    [self.file_name,self.path_name,filter_index] = uigetfile(allowed_file_extensions);
    if ~self.file_name
        return
    end
elseif strcmp(src.String,'<')
    if isempty(self.file_name)
        return
    else
        self.saveData;
        self.reset(false);

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
    if isempty(self.file_name)
        return
    else
        self.saveData;
        self.reset(false);


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
    [~,~,ext]=fileparts(self.file_name);
    filter_index = find(strcmp(['*' ext],allowed_file_extensions));
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


if ~isempty(self.handles)
    self.handles.main_fig.Name = self.file_name;
    self.redrawAxes;
end

% set the channel_stages
self.channel_stage = zeros(size(self.raw_data,2),1);
self.channel_ylims = zeros(size(self.raw_data,2),1);

% check if there is a .crabsort file already
file_name = joinPath(self.path_name, [self.file_name '.crabsort']);

if exist(file_name,'file') == 2
    disp('file exists -- need to load it and update the object')
    load(file_name,'crabsort_obj','-mat')
    
    % copy over properties from crabsort_obj into self
    fn = fieldnames(crabsort_obj);
    for i = 1:length(fn)
        if ~isempty(crabsort_obj.(fn{i}))
            self.(fn{i}) = crabsort_obj.(fn{i});
        end
    end

end


% remove mean for all channels that are names
for i = 1:length(self.data_channel_names)
    if isempty(self.data_channel_names{i})
        continue
    end

    if strcmp(self.data_channel_names{i},'temperature')
        continue
    end
    self.removeMean(i);
end

% update data_channel_names
for i = 1:length(self.data_channel_names)
    if ~isempty(self.data_channel_names{i})
        idx = find(strcmp(self.data_channel_names{i},self.channel_names));

        if isempty(self.handles)
            continue
        end

        self.handles.channel_label_chooser(i).Value = idx;

        if strcmp(self.data_channel_names{i},'temperature')
            self.handles.ax(i).YLim = [10 35];
            self.handles.ax(i).YTickMode = 'auto';

        end

    end
end

% make a putative_spikes matrix
self.putative_spikes = 0*self.raw_data;

if ~isempty(self.handles)
    self.showSpikes;
end
