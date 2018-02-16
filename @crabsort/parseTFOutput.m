%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% extracts metrics and other info from printed
% tensorflow output 

function [accuracy, nsteps] = parseTFOutput(o)

a = max(strfind(o,'accuracy'));
z = 1 + a + min(strfind(o(a+1:end),','));
accuracy = str2double(o(a+10:z-2));

a = max(strfind(o,'global_step'));
z = 1 + a + min(strfind(o(a+1:end),'}'));
nsteps = str2double(o(a+14:z-2));