%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% shows the saved automate_info in
% a human-readable format 

function showAutomateInfo(self,~,~)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


if isempty(self.common)
	disp('No automate info to show')
	return
end

if isfield(self.common,'automate_info')
	if isempty(self.common.automate_info)
		disp('No automate info to show')
		return
	end
else
	disp('No automate info to show')
	return
end

A  = self.common.automate_info;

for i = self.common.automate_channel_order
	if isempty(A(i).operation)
		continue
	end
	fprintf('\n')
	disp(['Switch to channel #' mat2str(i)])
	disp('===============================')
	for j  = 1:length(A(i).operation)
		operation = A(i).operation(j);
		fprintf('\n')
		disp(['------  Operation #' mat2str(j) ' ------ '])

		for k = 1:length(operation.property)
			fprintf(strjoin(operation.property{k},'.'))
			fprintf(' -> ')
			disp(mat2str(operation.value{k}))
		end

	end
end