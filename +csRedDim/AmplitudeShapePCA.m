
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% this is a plugin for crabsort.m
% computes the PCA on the spike shape, and peak amplitude
%  and then uses the top 2 components
% 
% created by Srinivas Gorur-Shandilya at 10:20 , 09 April 2014. Contact me at http://srinivas.gs/contact/
% 

function self = AmplitudeShapePCA(self)

channel = self.channel_to_work_with;

P = self.raw_data(self.putative_spikes(:,channel),channel);
P = P/std(P);



R = pca([P'; self.data_to_reduce]);
self.R{channel} = R(:,1:2)';


