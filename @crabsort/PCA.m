% crabsort plugin
% plugin_type = 'dim-red';
% plugin_dimension = 2; 
% 
% this is a plugin for crabsort.m
% reduces spikes to a amplitude, measured from the minimum to preceding maximum.
% 
% created by Srinivas Gorur-Shandilya at 10:20 , 09 April 2014. Contact me at http://srinivas.gs/contact/
% 

function PCA(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

R = pca(self.V_snippets);
self.R = R(:,1:2)';
