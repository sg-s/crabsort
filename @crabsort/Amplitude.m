% crabsort plugin
% plugin_type = 'dim-red';
% plugin_dimension = 2; 
% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% this is a plugin for crabsort.m
% reduces spikes to a amplitude, measured from the minimum to preceding maximum.
% 
% created by Srinivas Gorur-Shandilya at 10:20 , 09 April 2014. Contact me at http://srinivas.gs/contact/
% 

function Amplitude(self)

if self.verbosity > 9
	disp(mfilename)
end


if size(self.data_to_reduce,1) <= 2
	% do nothing
	self.R{self.channel_to_work_with} = self.data_to_reduce;
else
	V = self.getSnippets(self.channel_to_work_with);
	idx =  floor(self.sdp.t_before/self.dt*1e-3);
	self.R{self.channel_to_work_with} = max(V - V(idx,:));
end

