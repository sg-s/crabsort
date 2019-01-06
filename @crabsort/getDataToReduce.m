% 
%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% populates the data_to_reduce property of crabsort
% using the options on hand 

function getDataToReduce(self)


% always get the spike shape. this is always included
% in the data to reduce
data_to_reduce = self.getSnippets(self.channel_to_work_with);
original_data = data_to_reduce;

if self.handles.multi_channel_control.Value

	if self.verbosity > 5
		disp(['[' mfilename '] Using multi-channel spike shape...'])
	end

	% let's make sure we have the delays computed
	self.estimateDelay;

	if ~isempty(self.handles.multi_channel_control_text.String)
		
		N = strsplit(self.handles.multi_channel_control_text.String,',');

		for i = 1:length(N)
			N{i} = strtrim(N{i});
			assert(any(strcmp(self.common.data_channel_names,N{i})),'Unknown channel name')
			this_channel = find(strcmp(self.common.data_channel_names,N{i}));

			D = self.common.delays(self.channel_to_work_with,this_channel);

			spiketimes = find(self.putative_spikes(:,self.channel_to_work_with)) + D;


			% get some extra context 
			old_t_before = self.pref.t_before;
			old_t_after = self.pref.t_after;
			self.pref.t_before = self.pref.t_before*3;
			self.pref.t_after = self.pref.t_after*3;
			these_snippets = self.getSnippets(this_channel, spiketimes);

			self.pref.t_before = old_t_before;
			self.pref.t_after = old_t_after;

			% normalize to match scale of original data
			if ~isempty(original_data)
				these_snippets = these_snippets/self.common.y_scales(this_channel);
				these_snippets = these_snippets*self.common.y_scales(self.channel_to_work_with);
			end

			data_to_reduce = [data_to_reduce; these_snippets];

		end
	end


end


self.data_to_reduce = data_to_reduce;