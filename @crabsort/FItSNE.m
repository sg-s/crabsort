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
% clusters using fast Fourier transform-interpolated t-distributed stochastic neighborhood embedding (FIt-SNE)
% https://github.com/KlugerLab/FIt-SNE
%
% created by Alec Hoyland at 13:25 19 June 2019
% contact me at entropyvsenergy@posteo.de
%
% FIt-SNE requires a separate repository
% 1. Download the repository from: https://github.com/KlugerLab/FIt-SNE
%     or clone using git clone https://github.com/KlugerLab/FIt-SNE
% 2. Add the downloaded folder to your MATLAB path
%     >> addpath path/to/FIt-SNE
%     >> savepath
% 3. Download FFTW from http://www.fftw.org/ or get it for your operating system/distribution
% 4. From the root directory of FIt-SNE, run:
%     $ g++ -std=c++11 -O3  src/sptree.cpp src/tsne.cpp src/nbodyfft.cpp  -o bin/fast_tsne -pthread -lfftw3 -lm
%     If you are using Windows, instead go to https://github.com/KlugerLab/FIt-SNE and download the compiled binary
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
