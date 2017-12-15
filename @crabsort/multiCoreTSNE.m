% spikesort plugin
% plugin_type = 'dim-red';
% plugin_dimension = 2; 
% 
% created by Srinivas Gorur-Shandilya at 2:04 , 02 September 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function multiCoreTSNE(s)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

s.R = mctsne(s.V_snippets);