function LFPPlot(s,~,~)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    d = dbstack;
    cprintf('text',[mfilename ' called by ' d(2).name])
end

% save data
s.saveData;

% use the correct plugin 
[~,~,chosen_data_ext] = fileparts(s.file_name);
chosen_data_ext(1) =  [];

% then do some post-load stuff, like loading the first trace so that we see something when we load the file
plugin_to_use = find(strcmp('plot-spikes',{s.installed_plugins.plugin_type}).*(strcmp(chosen_data_ext,{s.installed_plugins.data_extension})));
assert(~isempty(plugin_to_use),'[ERR 42] Could not figure out how to read data from file.')
assert(length(plugin_to_use) == 1,'[ERR 43] Too many plugins bound to this file type. ')

if s.verbosity 
    cprintf('green','\n[INFO] ')
    cprintf(['Using plugin: ' s.installed_plugins(plugin_to_use).name])
end

eval(['plot_spikes_handle = @s.' s.installed_plugins(plugin_to_use).name ';'])
plot_spikes_handle('LFP');




