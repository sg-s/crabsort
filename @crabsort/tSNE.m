% spikesort plugin
% plugin_type = 'dim-red';
% plugin_dimension = 2; 
% 
% created by Srinivas Gorur-Shandilya at 2:04 , 02 September 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function tSNE(s)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end


% always use the fast tSNE algorith, as it is internally cached
disp(['hash of V_snippets is ' dataHash(s.V_snippets)])
s.R = fast_tsne(s.V_snippets, s.pref.no_dims, s.pref.init_dims, s.pref.perplexity,s.pref.theta, s.pref.max_iter)';
