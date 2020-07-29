% 'this function runs some tests on some known
% data to verify that some features work all right'
function [passed,total] = run_all_tests()


hashlib.test()


passed = 0;
failed = 0;

close all

S = getpref('crabsort');

assert(~isempty(S),'crabsort_test_data environment variable is unset. Cannot perform tests!')
assert(isfield(S,'test_data'),'crabsort_test_data environment variable is unset. Cannot perform tests!')

assert(~isempty(S.test_data),'crabsort_test_data environment variable is unset. Cannot perform tests!')


% check file formats 

corelib.cprintf('_white','Checking file handlers...\n\n')

all_folders = filelib.getAllFolders(S.test_data);




for i = 2:length(all_folders)

	self = crabsort;
	self.path_name = all_folders{i};

	[~,ext]=fileparts(all_folders{i});

	files = dir([all_folders{i} filesep '*.' ext]);

	for j = 1:length(files)


		self.file_name = files(j).name;

		fprintf(files(j).name)


		try
			self.loadFile;
			corelib.cprintf('g','  [OK]\n')
			passed = passed + 1;
		catch err
			corelib.cprintf('r','  [FAILED]\n')
			failed = failed + 1;
		
		end

	end

	close all


end


% check going to the next/previous file
corelib.cprintf('_white','Checking next/prev buttons...\n\n')
self = crabsort;
self.path_name = all_folders{2};
[~,ext]=fileparts(all_folders{2});
files = dir([all_folders{2} filesep '*.' ext]);

self.file_name = files(1).name;

self.loadFile;

fprintf('Next button: ')

try
	self.loadFile(self.handles.next_file_control);
	corelib.cprintf('g','  [OK]\n')
	passed = passed + 1;
catch err
	corelib.cprintf('r','  [FAILED]\n')
	failed = failed + 1;

end


fprintf('Prev button: ')

try
	self.loadFile(self.handles.prev_file_control);
	corelib.cprintf('g','  [OK]\n')
	passed = passed + 1;
catch err
	corelib.cprintf('r','  [FAILED]\n')
	failed = failed + 1;

end


% delete all NN data and nets
corelib.cprintf('_white','Checking NNdelete...\n\n')

fprintf('Delete all nets button: ')

try
	idx = find(strcmp({self.handles.menu_name(5).Children.Text},'Delete all nets'));
	self.NNdelete(self.handles.menu_name(5).Children(idx))
	corelib.cprintf('g','  [OK]\n')
	passed = passed + 1;
catch err
	corelib.cprintf('r','  [FAILED]\n')
	failed = failed + 1;

end

fprintf('Delete all NNdata button: ')

try
	idx = find(strcmp({self.handles.menu_name(5).Children.Text},'Delete all NN data'));
	self.NNdelete(self.handles.menu_name(5).Children(idx))
	corelib.cprintf('g','  [OK]\n')
	passed = passed + 1;
catch err
	corelib.cprintf('r','  [FAILED]\n')
	failed = failed + 1;

end


fprintf('\n\n')
corelib.cprintf('_white','Testing core functionality...\n\n')


% switch to pdn channel
self.channel_to_work_with = 2;


% test reset
fprintf('Testing redo : ')
try
	self.redo(false)
	assert(self.channel_stage(2) == 0,'Redo failed')
	corelib.cprintf('g','  [OK]\n')
	passed = passed + 1;

catch err
	corelib.cprintf('r','  [FAILED]\n')
	failed = failed + 1;


end


fprintf('Testing findSpikes : ')

try
	self.sdp.MinPeakProminence = 4;
	self.findSpikes;

	n_spikes = sum(self.putative_spikes(:,2));
	corelib.cprintf('g',[strlib.oval(n_spikes) ' spikes found\n'])
	passed = passed + 1;
catch err
	corelib.cprintf('r','  [FAILED]\n')
	failed = failed + 1;

end

fprintf('\n\n')
corelib.cprintf('_white','Testing core functionality...\n\n')



fprintf('\n\n')
corelib.cprintf('_white','Testing dimensionality reduction methods...\n\n')


try
	conda activate umap
catch
	warning('conda not installed, umap will probably fail')
end

dim_red_methods = self.installed_plugins.csRedDim;

for i = 1:length(dim_red_methods)


	fprintf(dim_red_methods{i})

	try

		self.redo;
		self.sdp.MinPeakProminence = 4;
		self.findSpikes;
		self.handles.method_control.Value = i;
		self.reduceDimensionsCallback;

		assert(self.channel_stage(2) == 2,'Channel stage could not be set')

		assert(length(self.R{2}) == sum(self.putative_spikes(:,2)),'Reduced data inconsistent')

		corelib.cprintf('g','  [OK]\n')

		passed = passed + 1;

	catch err
		keyboard
		corelib.cprintf('r','   [FAILED]\n')
		failed = failed + 1;
	end

end

close(self)
close all

total = passed + failed;





