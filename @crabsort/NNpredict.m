%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# NNpredict

**Syntax**

```
NNpredict(self, channel)
```

**Description**

makes predictions using a trained neural network

%}

function NNpredict(self, futz_factor)

channel = self.channel_to_work_with;
if isempty(channel)
	return
end


if nargin == 1
	futz_factor = self.futz_factor(channel);
end


if ~self.auto_predict && self.automate_action == crabsort.automateAction.none
	return
end




NNdata = self.common.NNdata(channel);

checkpoint_path = [self.path_name 'network' filesep self.common.data_channel_names{channel}];
H = NNdata.networkHash();
NN_dump_file = [checkpoint_path filesep H '.mat'];


if ~NNdata.canDetectSpikes() || exist(NN_dump_file,'file') ~= 2

	% maybe there is a default network we can use?
	this_nerve = self.common.data_channel_names{self.channel_to_work_with};

	SpikeSign = logical(self.handles.spike_sign_control.Value);

	

	NN_dump_file = [fileparts(fileparts(which('crabsort'))) filesep 'global-network' filesep this_nerve '_' mat2str(SpikeSign) '.network'];

	if exist(NN_dump_file,'file') ~= 2
		self.say('[ABORT] No network that I can use...')
		return
	end

	self.say('Using global network...')


	% OK, let's use the default SDP 
	self.sdp = crabsort.spikeDetectionParameters.default;

	if strcmp(upper(this_nerve),this_nerve)
		self.sdp.MinPeakProminence = 5;
		self.sdp.MinPeakHeight = self.handles.ax.ax(channel).YLim(1)
		self.sdp.MaxPeakHeight = self.handles.ax.ax(channel).YLim(2);
		self.findSpikes()
		spiketimes = find(self.putative_spikes(:,channel));

		if length(spiketimes) == 0
			self.say('No spikes detected, nothing to do.')
			self.channel_stage(channel) = 3;
			return
		end

		% get spike shapes
		X = self.getSnippets(channel,spiketimes);

				% resample
		old_time = linspace(-self.sdp.t_before,self.sdp.t_after,size(X,1));
		new_time = linspace(-self.sdp.t_before,self.sdp.t_after,91);

		new_X = NaN(91,size(X,2));
		for i = 1:size(X,2)
			new_X(:,i) = interp1(old_time,X(:,i),new_time);
		end

		X = new_X;
		clear new_X;


	else

		% be smart about choosing SDP

		self.sdp.spike_sign = logical(self.handles.spike_sign_control.Value);
		yl = self.handles.ax.ax(channel).YLim(1);

		self.sdp.MinPeakProminence = abs(self.handles.ax.ax(channel).YLim(1)/3);
		self.sdp.MinPeakHeight = 0;
		self.sdp.MaxPeakHeight = self.handles.ax.ax(channel).YLim(2);
		self.findSpikes()
		spiketimes = find(self.putative_spikes(:,channel));

		if length(spiketimes) == 0
			self.say('No spikes detected, nothing to do.')
			self.channel_stage(channel) = 3;
			return
		end


		% get spike shapes
		X = self.getSnippets(channel,spiketimes);

		% normalize
		% extracellular 
		y_scale = abs(self.handles.ax.ax(channel).YLim(1));
		for i = 1:size(X,2)
			X(:,i) = X(:,i)/y_scale;
		end


		% resample
		old_time = linspace(-self.sdp.t_before,self.sdp.t_after,size(X,1));
		new_time = linspace(-self.sdp.t_before,self.sdp.t_after,91);

		new_X = NaN(91,size(X,2));
		for i = 1:size(X,2)
			new_X(:,i) = interp1(old_time,X(:,i),new_time);
		end

		X = new_X;
		clear new_X;


	end

	

	% load trained net
	load(NN_dump_file,'trainedNet','-mat');

	% predict

	N = size(X,2);
	SZ = size(X,1);
	X = reshape(X,SZ,1,1,N);


	[Y_pred, scores] = classify(trainedNet,X);
	N = size(scores,2);
	uncertain_spikes = max(scores,[],2) < (1/(N-1)*(.4)) + .4;
	putative_spikes = find(self.putative_spikes(:,channel));
	uncertain_spikes = putative_spikes(uncertain_spikes);

	cats = categories(Y_pred);
	% store in spikes
	for i = 1:length(cats)
		if strcmp(char(cats(i)),'Noise')
			continue
		end
		self.spikes.(this_nerve).(char(cats(i))) = spiketimes(Y_pred == cats(i));
	end


	% show the uncertain spikes
	self.handles.ax.uncertain_spikes(channel).XData = uncertain_spikes*self.dt;
	yrange = diff(self.handles.ax.ax(channel).YLim);

	if self.sdp.spike_sign
		self.handles.ax.uncertain_spikes(channel).YData = self.raw_data(uncertain_spikes,channel)+yrange*.07;
		self.handles.ax.uncertain_spikes(channel).Marker = 'v';
	else
		self.handles.ax.uncertain_spikes(channel).YData = self.raw_data(uncertain_spikes,channel)-yrange*.07;
		self.handles.ax.uncertain_spikes(channel).Marker = '^';
	end



	self.channel_stage(channel) = 3;

	uxlib.enable(self.handles.manual_panel)

	self.putative_spikes(:,channel) = 0;
	self.showSpikes(channel);

	self.say('DONE. Spikes classified using global network')

	self.common.channel_name_lock(self.channel_to_work_with) = true;
	self.handles.ax.channel_label_chooser(self.channel_to_work_with).Enable = 'off';

	% run PostPredictAction, if any
	if ~isempty(self.PostPredictAction) && strcmp(self.common.data_channel_names{self.channel_to_work_with},self.PostPredictAction.channel)
		self.PostPredictAction.method(self.PostPredictAction.arguments{:})

	end

	return


end





% iteratively mess with the futz_factor till we are sure
% we should be getting all spikes




if self.isIntracellular(channel)
	% just find the damn spikes, decay be damned
	self.loadSDPFromNNdata()
	self.findSpikes()
	spiketimes = find(self.putative_spikes(:,channel));

	
else
	futz_factor_scale = self.futz_factor(channel);

	if NNdata.sdp.spike_sign

		goon = true;
		smallest_spike = min(max(NNdata.raw_data(:,NNdata.label_idx~='Noise')));

		while goon

			self.loadSDPFromNNdata(futz_factor)


			self.findSpikes()
			spiketimes = find(self.putative_spikes(:,channel));


			if isempty(spiketimes)
				futz_factor = futz_factor*futz_factor_scale;
				continue
			end

			V_snippets = self.getSnippets(channel,spiketimes);
			V_snippets(:,(sum(V_snippets) == 0)) = NaN;


			if futz_factor < .1
				warning('Futz factor is too small to resolve spikes.')
				goon = false;

			end

			if nanmin(nanmax(V_snippets)) > smallest_spike 
				futz_factor = futz_factor*futz_factor_scale;
			else

				goon = false;
			end


			self.futz_factor(channel) = futz_factor;

			
		end
	else
		goon = true;
		smallest_spike = -min(abs(min(NNdata.raw_data(:,NNdata.label_idx~='Noise'))));

		while goon

			self.loadSDPFromNNdata(futz_factor)

			self.findSpikes()
			spiketimes = find(self.putative_spikes(:,channel));

			if isempty(spiketimes)
				futz_factor = futz_factor*futz_factor_scale;
				continue
			end


			V_snippets = self.getSnippets(channel,spiketimes);
			V_snippets(:,(sum(V_snippets) == 0)) = NaN;

			if futz_factor < .1
				warning('Futz factor is too small to resolve spikes.')
				goon = false;
			end

			if nanmin(nanmin(V_snippets)) < smallest_spike 
				futz_factor = futz_factor*futz_factor_scale;
			else
				goon = false;
			end

			self.futz_factor(channel) = futz_factor;
			
		end
	end

end



n_spikes = length(spiketimes);

this_nerve = self.common.data_channel_names{channel};

% load the net 
load(NN_dump_file,'trainedNet');

if n_spikes == 0
	self.say('No spikes detected, nothing to do.')
	self.channel_stage(channel) = 3;

	% also create empty arrays
	neuron_names = trainedNet.Layers(end).ClassNames;
	for i = 1:length(neuron_names)
		if ~strcmp(neuron_names{i},'Noise')
			self.spikes.(this_nerve).(neuron_names{i}) = [];
		end
	end
	self.common.channel_name_lock(self.channel_to_work_with) = true;
	self.handles.ax.channel_label_chooser(self.channel_to_work_with).Enable = 'off';


	if ~isempty(self.PostPredictAction) && strcmp(self.common.data_channel_names{self.channel_to_work_with},self.PostPredictAction.channel)
		self.PostPredictAction.method(self.PostPredictAction.arguments{:})

	end

	return
else
	self.say([strlib.oval(n_spikes) ' spikes detected; using NN to sort...'])
end

self.getDataToReduce()

X = self.data_to_reduce;


N = size(X,2);
SZ = size(X,1);
X = reshape(X,SZ,1,1,N);

% rescale
X = X/NNdata.norm_factor;



[Y_pred, scores] = classify(trainedNet,X);


N = size(scores,2);
uncertain_spikes = max(scores,[],2) < (1/(N-1)*(.4)) + .4;






putative_spikes = find(self.putative_spikes(:,channel));
uncertain_spikes = putative_spikes(uncertain_spikes);


% overwrite any predictions from the NN using manual annotations
% stored in NNdata
manual_labels = NNdata.label_idx(NNdata.file_idx == self.getFileSequence);

uniq_manual_labels = unique(NNdata.label_idx);

if any(NNdata.file_idx == self.getFileSequence)
	manually_labelled_spikes = NNdata.spiketimes(NNdata.file_idx == self.getFileSequence);



	uncertain_spikes = setdiff(uncertain_spikes,manually_labelled_spikes);

	if ~isempty(manual_labels)
	
		for i = 1:length(uniq_manual_labels)
			mark_as_spike = ismember(putative_spikes,manually_labelled_spikes(manual_labels==uniq_manual_labels(i)));
			Y_pred(mark_as_spike) = uniq_manual_labels(i);
		end
	end
end


% store in spikes
for i = 1:length(uniq_manual_labels)
	if strcmp(char(uniq_manual_labels(i)),'Noise')
		continue
	end
	self.spikes.(this_nerve).(char(uniq_manual_labels(i))) = spiketimes(Y_pred == uniq_manual_labels(i));
end


% show the uncertain spikes
self.handles.ax.uncertain_spikes(channel).XData = uncertain_spikes*self.dt;
yrange = diff(self.handles.ax.ax(channel).YLim);

if self.sdp.spike_sign
	self.handles.ax.uncertain_spikes(channel).YData = self.raw_data(uncertain_spikes,channel)+yrange*.07;
	self.handles.ax.uncertain_spikes(channel).Marker = 'v';
else
	self.handles.ax.uncertain_spikes(channel).YData = self.raw_data(uncertain_spikes,channel)-yrange*.07;
	self.handles.ax.uncertain_spikes(channel).Marker = '^';
end







self.channel_stage(channel) = 3;

uxlib.enable(self.handles.manual_panel)

self.putative_spikes(:,channel) = 0;
self.showSpikes(channel);

self.say('DONE. Spikes classified using NN')

self.common.channel_name_lock(self.channel_to_work_with) = true;
self.handles.ax.channel_label_chooser(self.channel_to_work_with).Enable = 'off';


if ~isempty(self.PostPredictAction) && strcmp(self.common.data_channel_names{self.channel_to_work_with},self.PostPredictAction.channel)
	self.PostPredictAction.method(self.PostPredictAction.arguments{:})

end