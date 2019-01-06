%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% flips b/w finding +ve and -ve spikes

function toggleSpikeSign(self,~,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end

self.spd = self.handles.spike_sign_control.Value;

if self.spd
	set(self.handles.spike_sign_control,'String','+ve spikes')
else
	set(self.handles.spike_sign_control,'String','-ve spikes')
end

self.findSpikes;
