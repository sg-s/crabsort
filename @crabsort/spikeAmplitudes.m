% spikeAmplitudes.m
% Dimensionality Reduction Plugin for spikesort: 1D spike amplitudes
% 
% this is a plugin for spikesort.m
% reduces spikes to a amplitude, measured from the minimum to preceding maximum.
% 
% created by Srinivas Gorur-Shandilya at 10:20 , 09 April 2014. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
function varargout = spikeAmplitudes(s,V,loc)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

h = (40*1e-4)/s.pref.deltat; % deltat in seconds
% 1D - find total spike amplitude for each
R = zeros*loc;
loc_max = 0*loc;
for i = 1:length(loc)
	try
		if s.pref.invert_V
			before = max([loc(i)-h loc(i-1)]);
			[R(i),loc_max(i)] = max(V(before:loc(i)) - V(loc(i)));
			loc_max(i) = loc_max(i) + before;
		else
			after = min([length(V) loc(i)+h]);
			[R(i),loc_max(i)] =  max(V(loc(i)) - V(loc(i):after));
		end
	catch
	end
end

if nargout 
	varargout{1} = R;
else
	% it's being called a dim red tool
	s.R = R;
end