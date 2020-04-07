% crabsort.common
% class that defines the common
% object type
%
% the common object stores information
% that is common to all files in a given data set
% for example, the names of the channels
% 

classdef common


properties 


	y_scales double
	delays
	
	data_channel_names cell


	show_hide_channels logical
	channel_name_lock logical


	NNdata crabsort.NNdata

end

properties (SetAccess = private)
	n_channels double
end


methods

	function self = common(n_channels)

		self.n_channels = n_channels;

		self.channel_name_lock = false(n_channels,1);

		self.y_scales = NaN(n_channels,1);

		self.show_hide_channels = true(n_channels,1);

		self.delays = NaN(n_channels,n_channels);

		self.data_channel_names = cell(n_channels,1);

		self.NNdata = crabsort.NNdata(n_channels);




	end

	function self = set.y_scales(self,value)

		if ~isempty(self.n_channels)

			assert(size(value,1)==self.n_channels,'y_scales is the wrong size')
			assert(size(value,2)==1,'y_scales is the wrong size')
		end
		self.y_scales = value;


	end

	function self = set.show_hide_channels(self,value)

		if ~isempty(self.n_channels)
			assert(size(value,1)==self.n_channels,'show_hide_channels is the wrong size')
			assert(size(value,2)==1,'show_hide_channels is the wrong size')
		end

		self.show_hide_channels = value;


	end

	function self = set.data_channel_names(self,value)

		if ~isempty(self.n_channels)
			assert(size(value,1)==self.n_channels,'data_channel_names is the wrong size')
			assert(size(value,2)==1,'data_channel_names is the wrong size')
		end

		self.data_channel_names = value;

	end

	function self = set.delays(self,value)

		if ~isempty(self.n_channels)
			assert(size(value,1)==self.n_channels,'delays is the wrong size')
			assert(size(value,2)==self.n_channels,'delays is the wrong size')
		end
		self.delays = value;

	end

	function self = set.channel_name_lock(self,value)

		if ~isempty(self.n_channels)
			assert(size(value,1)==self.n_channels,'channel_name_lock is the wrong size')
			assert(size(value,2)==1,'channel_name_lock is the wrong size')
		end
		self.channel_name_lock = value;

	end



end

end % classdef