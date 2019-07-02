%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% 
% figure out which plugins and installed and link them
% so we can use them
% 
function varargout = plugins()

p = struct;

plugin_types = {'csloadFile','csRedDim','csCluster'};


for j = 1:length(plugin_types)
    a = what(plugin_types{j});

    p.(plugin_types{j}) = '';

    for i = 1:length(a)
        p.(plugin_types{j}) = [p.(plugin_types{j}); cellfun(@(x) strrep(x, '.m',''), a.m, 'UniformOutput',false)];
    end

end


if nargout == 0 
    % print things out
    disp('The following plugins for crabsort have been installed:')

    for j = 1:length(plugin_types)
        fprintf('\n')
        disp(['Plugin type: ' plugin_types{j}])
        for i = 1:length(p.(plugin_types{j}))
            disp(p.(plugin_types{j}){i})
        end
        
    end


else
    varargout{1} = p;
end