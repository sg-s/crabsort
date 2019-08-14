function fatal = checkSortedSerial(allfiles, neurons, early_exit)

fatal = false;
load([allfiles.folder filesep allfiles.name],'-mat','crabsort_obj')

self = crabsort_obj;


% check if the entire file is ignored
if ~isempty(self.ignore_section) && ~isempty(self.ignore_section.ons)
	if self.ignore_section.ons(1) == 1 & self.ignore_section.offs(1) == self.raw_data_size(1)
		return
	end
end

% figure out all the neurons that exist in self.spikes
sorted_neurons = {};


if ~isstruct(self.spikes)
	fatal = true;
	corelib.cprintf('red',['No spikes at all in ' allfiles.name '\n'])
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
		corelib.cprintf('red',['No spikes found for ' neurons{j} ' on ' allfiles.name '\n'])
		fatal = true;
		if early_exit
			return
		end

	end
end


% check that the channel_stages for req nerves are OK
if sum(self.channel_stage == 3) >= length(neurons)
else
	corelib.cprintf('red',['Some channels not sorted on ' allfiles.name '\n'])
	fatal = true;

	if early_exit
		return
	end

end