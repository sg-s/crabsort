%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% attempts to go through all files and run through
% the process that was done earlier manually 

function runAutomateOnCurrentChannel(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

channel = self.channel_to_work_with;
if isempty(channel)
	return
end

% check if this channel is already done
if isfield(self.spikes,(self.common.data_channel_names{self.channel_to_work_with}))
	fn = fieldnames(self.spikes.(self.common.data_channel_names{self.channel_to_work_with}));
	if ~isempty(self.spikes.(self.common.data_channel_names{self.channel_to_work_with}).(fn{1}))
		return
	end
end

% check if there is a tensorflow model for this channel
% that is accurate enough
use_tf = false;
try
	if max(self.common.tf.metrics(self.channel_to_work_with).accuracy) > self.pref.tf_predict_accuracy
		use_tf = true;
	end
catch
end
if use_tf
	self.predict;
	return
end

% go through all the steps in the operation 
for k = 1:length(self.common.automate_info(channel).operation)
	operation = self.common.automate_info(channel).operation(k);

	self.current_operation = k;

	% assign all properties
	% we have to be careful here because of MATLAB's
	% poor architecture of popupmenu items 
	for l = 1:length(operation.property)
		if any(strcmp(operation.property{l},'method_control'))
			V = find(strcmp(self.handles.method_control.String,operation.value{l}));
			assert(~isempty(V),'[#444] Fatal error in automate: automate wants to perform a dimensionality reduction method that cant be found any more.')
			self.handles.method_control.Value = V;
		elseif  any(strcmp(operation.property{l},'cluster_control'))
			V = find(strcmp(self.handles.cluster_control.String,operation.value{l}));
			assert(~isempty(V),'[#445] Fatal error in automate: automate wants to perform a clustering method that cant be found any more.')
			self.handles.cluster_control.Value = V;
		else
			p = operation.property{l};
			setfield(self,p{:},operation.value{l});
		end
	end

	% execute the method
	operation.method(self);

	% if we find too few spikes, give up
	n_spikes = sum(self.putative_spikes(:,self.channel_to_work_with));
	min_n_spikes_to_process_channel
	if k == 1 && n_spikes < self.pref.min_n_spikes_to_process_channel
		return
	end
end