

function [accuracy, nsteps] = parseTFOutput(o)

a = max(strfind(o,'accuracy'));
z = 1 + a + min(strfind(o(a+1:end),','));
accuracy = str2double(o(a+10:z-2));

a = max(strfind(o,'global_step'));
z = 1 + a + min(strfind(o(a+1:end),'}'));
nsteps = str2double(o(a+14:z-2));