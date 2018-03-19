%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% 
% shows the installed plugins with associated methods
% 
function varargout = plugins(s)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

p.name = '';
p.plugin_type = '';
p.plugin_dimension = [];
p.data_extension = '';


if ~nargout
    disp('The following plugins for spikesort have been installed:')
end

m = dir([fileparts(which(mfilename)) filesep '*.m']);

c = 1;
for i = 1:length(m)
    % read the file
    t = lineRead([fileparts(which(mfilename)) filesep m(i).name]);

    if ~any(strfind(t{1},'crabsort plugin'))
        continue
    end

    p(c).name = strrep(m(i).name,'.m','');
    
    plugin_type = 'unknown';
    data_extension = 'n/a';
    plugin_dimension = NaN;

    eval(strrep(t{2},'%',''));
    eval(strrep(t{3},'%',''));

    p(c).plugin_dimension = plugin_dimension;
    p(c).plugin_type = plugin_type;
    p(c).data_extension = data_extension;
    c = c + 1;
end

if ~nargout
    cprintf('_text','Plugin ')
    cprintf('text',repmat(' ',1,10))
    cprintf('_text','Type ')
    cprintf('text',repmat(' ',1,10))
    cprintf('_text','Dimension\n')
    for i = 1:length(p)
        fprintf(p(i).name)
        fprintf(repmat(' ',1,16 - length(p(i).name)));
        fprintf(p(i).plugin_type)
        fprintf(repmat(' ',1,16 - length(p(i).plugin_type)));
        fprintf(oval(p(i).plugin_dimension))
        fprintf('\n')
    end
else
    s.installed_plugins = p;
    varargout{1} = s;
end
