% check if all files are sorted
%
% usage:
%
% crabsort.checkSorted('857_108',{'PD','LP'})
% 
function fatal = checkSorted(allfiles, neurons, early_exit)

if nargin < 3
	if length(allfiles) > 50
		early_exit = false;
	else
		early_exit = true;
	end
end

fatal = false;

if ischar(allfiles)
	allfiles = pathlib.join(getpref('crabsort','store_spikes_here'),allfiles);
end

if ~isstruct(allfiles) && isfolder(allfiles)
	allfiles = dir(pathlib.join(allfiles,'*.crabsort'));
end

% note that setting early_exit to false can actually be faster in
% many cases because it uses the parallel pool 


if early_exit

	for i = 1:length(allfiles)
		fatal = crabsort.analysis.checkSortedSerial(allfiles(i), neurons, true);
		if fatal
			return
		end
	end

else
	fatal = false(length(allfiles),1);
	for i = 1:length(allfiles)
		fatal(i) = crabsort.analysis.checkSortedSerial(allfiles(i), neurons, false);

	end
	fatal = ~all(fatal);

end