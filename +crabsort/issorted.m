function issorted(varargin)


error('dont use this -- not needed (consolidate does this)')

% options and defaults
options.data_dir = pwd;
options.nerves = {};



% validate and accept options
if mathlib.iseven(length(varargin))
	for ii = 1:2:length(varargin)-1
	temp = varargin{ii};
    if ischar(temp)
    	if ~any(find(strcmp(temp,fieldnames(options))))
    		disp(['Unknown option: ' temp])
    		disp('The allowed options are:')
    		disp(fieldnames(options))
    		error('UNKNOWN OPTION')
    	else
    		options.(temp) = varargin{ii+1};
    	end
    end
end
elseif isstruct(varargin{1})
	% should be OK...
	options = varargin{1};
else
	error('Inputs need to be name value pairs')
end

allfiles = dir([options.data_dir filesep '*.crabsort']);

if isempty(allfiles)
	error('No data found')
end


assert(~isempty(options.nerves),'nerves not specified')
assert(iscell(options.nerves),'nerves should be a cell array')

% load the common data
load([allfiles(1).folder filesep 'crabsort.common'],'-mat','common')


nerve_idx = NaN(length(options.nerves),1);

for i = 1:length(options.nerves)
	this_nerve = options.nerves{i};
	assert(any(strcmp(this_nerve,common.data_channel_names)),['This nerve could not be found in the data: ' this_nerve])

	nerve_idx(i) = find(strcmp(this_nerve,common.data_channel_names));

end



