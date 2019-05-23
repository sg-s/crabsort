% check if all files are sorted
function fatal = checkSorted(allfiles, neurons, early_exit)

if nargin < 3
	early_exit = false;
end

fatal = false;
for i = 1:length(allfiles)
	load([allfiles(i).folder filesep allfiles(i).name],'-mat','crabsort_obj')

	self = crabsort_obj;


	% figure out all the neurons that exist in self.spikes
	sorted_neurons = {};
	if ~isstruct(self.spikes)
		fatal = true;
		corelib.cprintf('red',['No spikes at all in ' allfiles(i).name '\n'])
		if early_exit
			return
		end
	else
		fn = fieldnames(self.spikes);
		for j = 1:length(fn)
			sorted_neurons = [sorted_neurons; fieldnames(self.spikes.(fn{j}))];
		end
	end


	% check that required neurons exist in spikes
	for j = 1:length(neurons)
		if ~any(strcmp(neurons{j},sorted_neurons))
			corelib.cprintf('red',['No spikes found for ' neurons{j} ' on ' allfiles(i).name '\n'])
			fatal = true;
			if early_exit
				return
			end

		end
	end


	% check that the channel_stages for req nerves are OK
	if sum(self.channel_stage == 3) >= length(neurons)
	else
		corelib.cprintf('red',['Some channels not sorted on ' allfiles(i).name '\n'])
		fatal = true;

		if early_exit
			return
		end

	end
end