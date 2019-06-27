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

% opts - a struct with the following possible parameters
%                   opts.no_dims - dimensionality of the embedding
%                        Default 2.
%                   opts.perplexity - perplexity is used to determine the
%                       bandwidth of the Gaussian kernel in the input
%                       space.  Default 30.
%                   opts.theta - Set to 0 for exact.  If non-zero, then will use either
%                       Barnes Hut or FIt-SNE based on opts.nbody_algo.  If Barnes Hut, then
%                       this determins the accuracy of BH approximation.
%                       Default 0.5.
%                   opts.max_iter - Number of iterations of t-SNE to run.
%                       Default 1000.
%                   opts.nbody_algo - if theta is nonzero, this determins whether to
%                        use FIt-SNE or Barnes Hut approximation. Default is FIt-SNE.
%                        set to be 'bh' for Barnes Hut
%                   opts.knn_algo - use vp-trees (as in bhtsne) or approximate nearest neighbors (default).
%                        set to be 'vptree' for vp-trees
%                   opts.early_exag_coeff - coefficient for early exaggeration
%                       (>1). Default 12.
%                   opts.stop_early_exag_iter - When to switch off early exaggeration.
%                       Default 250.
%                   opts.start_late_exag_iter - When to start late
%                       exaggeration. set to -1 to not use late exaggeration
%                       Default -1.
%                   opts.late_exag_coeff - Late exaggeration coefficient.
%                      Set to -1 to not use late exaggeration.
%                       Default -1
%                   opts.no_momentum_during_exag - Set to 0 to use momentum
%                       and other optimization tricks. 1 to do plain,vanilla
%                       gradient descent (useful for testing large exaggeration
%                       coefficients)
%                   opts.nterms - If using FIt-SNE, this is the number of
%                                  interpolation points per sub-interval
%                   opts.intervals_per_integer - See opts.min_num_intervals
%                   opts.min_num_intervals - Let maxloc = ceil(max(max(X)))
%                   and minloc = floor(min(min(X))). i.e. the points are in
%                   a [minloc]^no_dims by [maxloc]^no_dims interval/square.
%                   The number of intervals in each dimension is either
%                   opts.min_num_intervals or ceil((maxloc -
%                   minloc)/opts.intervals_per_integer), whichever is
%                   larger. opts.min_num_intervals must be an integer >0,
%                   and opts.intervals_per_integer must be >0. Default:
%                   opts.min_num_intervals=50, opts.intervals_per_integer =
%                   1
%
%                   opts.sigma - Fixed sigma value to use when perplexity==-1
%                        Default -1 (None)
%                   opts.K - Number of nearest neighbours to get when using fixed sigma
%                        Default -30 (None)
%
%                   opts.initialization - N x no_dims array to intialize the solution
%                        Default: None
%
%                   opts.load_affinities - can be 'load', 'save', or 'none' (default)
%                        If 'save', input similarities are saved into a file.
%                        If 'load', input similarities are loaded from a file and not computed
%
%                   opts.perplexity_list - if perplexity==0 then perplexity combination will
%                        be used with values taken from perplexity_list. Default: []
%                   opts.df - Degree of freedom of t-distribution, must be greater than 0.
%                        Values smaller than 1 correspond to heavier tails, which can often
%                        resolve substructure in the embedding. See Kobak et al. (2019) for
%                        details. Default is 1.0

function FItSNE(self)

  if size(self.data_to_reduce, 1) <= 2
    % do nothing
    self.R{self.channel_to_work_with} = self.data_to_reduce;
  else
    R = fast_tsne(self.data_to_reduce');
    self.R{self.channel_to_work_with} = R(:, 1:2)';
  end

end % function
