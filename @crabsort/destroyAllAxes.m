

function destroyAllAxes(self)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% destroy it all
if isfield(self.handles,'ax')
	for i = 1:length(self.handles.ax)
		delete(self.handles.ax(i));
	end
	self.handles = rmfield(self.handles,'ax');
end

% destroy the channel pickers
if isfield(self.handles,'channel_label_chooser')
	for i = 1:length(self.handles.channel_label_chooser)
		delete(self.handles.channel_label_chooser(i));
	end
	self.handles = rmfield(self.handles,'channel_label_chooser');
end

% also destroy the labels for the built in channel names
if isfield(self.handles,'channel_names')
	for i = 1:length(self.handles.channel_names)
		delete(self.handles.channel_names(i));
	end
	self.handles = rmfield(self.handles,'channel_names');
end

% destroy the "recording" indicators 
if isfield(self.handles,'recording')
	for i = 1:length(self.handles.recording)
		delete(self.handles.recording(i));
	end
	self.handles = rmfield(self.handles,'recording');
end

% destroy the "automate" indicators
if isfield(self.handles,'has_automate')
	for i = 1:length(self.handles.has_automate)
		delete(self.handles.has_automate(i));
	end
	self.handles = rmfield(self.handles,'has_automate');
end
