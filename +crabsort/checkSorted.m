% check if all files are sorted
function fatal = checkSorted(allfiles, neurons, early_exit)

if nargin < 3
	early_exit = false;
end

fatal = false;
for i = 1:length(allfiles)
	load([allfiles(i).folder filesep allfiles(i).name],'-mat','crabsort_obj')

	self = crabsort_obj;


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