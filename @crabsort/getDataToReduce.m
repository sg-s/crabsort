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

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


data_to_reduce = [];

if self.handles.spike_shape_control.Value

	if self.verbosity > 5
		disp(['[' mfilename '] Using spike shape...'])
	end

	data_to_reduce = self.getSnippets(self.channel_to_work_with);
end

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
				these_snippets = these_snippets/mean(std(these_snippets));
				these_snippets = these_snippets*mean(std(original_data));
			end

			data_to_reduce = [data_to_reduce; these_snippets];

		end
	end


end

if self.handles.time_before_control.Value


	if self.verbosity > 5
		disp(['[' mfilename '] Using time before information...'])
	end

	% first, we need to figure out what nerves to compare to
	if isempty(self.handles.time_before_nerves.String)
		nerves = fieldnames(self.spikes);
	else
		nerves = self.handles.time_before_nerves.String;
	end  

	if ~iscell(nerves)
		nerves = {nerves};
	end


	% get times to closest spikes on other nerves in the past
	relative_times = self.measureTimesToIdentifiedSpikes(nerves,'future');

	data_to_reduce = [data_to_reduce; relative_times];
end

if self.handles.time_after_control.Value

	if self.verbosity > 5
		disp(['[' mfilename '] Using time after information...'])
	end

	% first, we need to figure out what nerves to compare to
	if isempty(self.handles.time_after_nerves.String)
		nerves = fieldnames(self.spikes);
	else
		nerves = self.handles.time_after_nerves.String;
	end 

	if ~iscell(nerves)
		nerves = {nerves};
	end


	% get times to closest spikes on other nerves in the past
	relative_times = self.measureTimesToIdentifiedSpikes(nerves,'past');

	data_to_reduce = [data_to_reduce; relative_times];

end

self.data_to_reduce = data_to_reduce;