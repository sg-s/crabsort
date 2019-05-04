% reads pref file and determines neurons
% useful in autocompleting commands

function N = findNeuronsInPrefFile()

pref = corelib.readPref(fileparts(fileparts(which('crabsort'))));

N = {};
fn = fieldnames(pref.nerve2neuron);

for i = 1:length(fn)
	N = [N pref.nerve2neuron.(fn{i})];
end

N = unique(N);