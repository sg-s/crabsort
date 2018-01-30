%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% attempts to go through all files and run through
% the process that was done earlier manually 

function runAutomateOnCurrentChannel(self)


channel = self.channel_to_work_with;

% check if this channel is already done
if isfield(self.spikes,(self.common.data_channel_names{self.channel_to_work_with}))
	fn = fieldnames(self.spikes.(self.common.data_channel_names{self.channel_to_work_with}));
	if ~isempty(self.spikes.(self.common.data_channel_names{self.channel_to_work_with}).(fn{1}))
		return
	end
end

% go through all the steps in the operation 
for k = 1:length(self.common.automate_info(channel).operation)
	operation = self.common.automate_info(channel).operation(k);

	self.current_operation = k;

	% assign all properties
	for l = 1:length(operation.property)
		p = operation.property{l};
		setfield(self,p{:},operation.value{l});
	end

	% execute the method
	operation.method(self);
end