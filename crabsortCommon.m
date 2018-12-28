% class that defines the common
% object type

classdef crabsortCommon


properties 


	y_scales@double
	delays
	
	data_channel_names@cell


	show_hide_channels@logical
	channel_name_lock@logical


	NNdata@crabsortNNdata

end

properties (SetAccess = private)
	n_channels@double
end


methods

	function common = crabsortCommon(n_channels)

		common.n_channels = n_channels;

		common.channel_name_lock = false(n_channels,1);

		assert(n_channels > 0,'n_channels must be > 0')
		common.y_scales = NaN(n_channels,1);

		common.show_hide_channels = true(n_channels,1);

		common.delays = NaN(n_channels,n_channels);

		common.data_channel_names = cell(n_channels,1);

		common.NNdata = crabsortNNdata(n_channels);




	end

	function common = set.y_scales(common,value)

		if ~isempty(common.n_channels)

			assert(size(value,1)==common.n_channels,'y_scales is the wrong size')
			assert(size(value,2)==1,'y_scales is the wrong size')
		end
		common.y_scales = value;


	end

	function common = set.show_hide_channels(common,value)

		if ~isempty(common.n_channels)
			assert(size(value,1)==common.n_channels,'show_hide_channels is the wrong size')
			assert(size(value,2)==1,'show_hide_channels is the wrong size')
		end

		common.show_hide_channels = value;


	end

	function common = set.data_channel_names(common,value)

		if ~isempty(common.n_channels)
			assert(size(value,1)==common.n_channels,'data_channel_names is the wrong size')
			assert(size(value,2)==1,'data_channel_names is the wrong size')
		end

		common.data_channel_names = value;

	end

	function common = set.delays(common,value)

		if ~isempty(common.n_channels)
			assert(size(value,1)==common.n_channels,'delays is the wrong size')
			assert(size(value,2)==common.n_channels,'delays is the wrong size')
		end
		common.delays = value;

	end

	function common = set.channel_name_lock(common,value)

		if ~isempty(common.n_channels)
			assert(size(value,1)==common.n_channels,'channel_name_lock is the wrong size')
			assert(size(value,2)==1,'channel_name_lock is the wrong size')
		end
		common.channel_name_lock = value;

	end



end

end % classdef