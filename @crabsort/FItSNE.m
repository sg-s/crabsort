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
% clusters using fast Fourier transform-interpolated t-distributed stochastic neighborhood embedding
% https://github.com/KlugerLab/FIt-SNE
%
% created by Alec Hoyland at 13:25 19 June 2019
% contact me at entropyvsenergy@posteo.de
%

function FItSNE(self)

  if size(self.data_to_reduce, 1) <= 2
    % do nothing
    self.R{self.channel_to_work_with} = self.data_to_reduce;
  else
    R = fast_tsne(self.data_to_reduce);
    self.R{self.channel_to_work_with} = R(:, 1:2)';
  end

end % function
