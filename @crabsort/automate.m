%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# automate

**Syntax**

```
automate(self,~,~)
```

**Description**

This method is a callback function of new_spike_type
and activates the new spike mode in manual override

%}
function automate(self,src,~)

if strcmp(src.Text,'Stop')
	self.automate_action = crabsort.automateAction.none;
	return
end


% OK, something is being started. so let's stop the timer

% cancel all workers, because we're going to run
% some automate action
cancel(self.workers)
stop(self.timer_handle)

self.auto_predict = false;


switch src.Text
case 'All channels/All files'
	self.automate_action = crabsort.automateAction.all_channels_all_files;
case 'This channel/All files'
	self.automate_action = crabsort.automateAction.this_channel_all_files;

case 'All channels/This file'
	self.automate_action = crabsort.automateAction.all_channels_this_file;
case 'Stop'

otherwise
	error('Unknown caller to automate')
end


self.runAutomateAction();

