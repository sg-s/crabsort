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


%}
function automate(self,src,~)


% remove check mark on all automate actions
M = src.Parent.Children;
for i = 1:length(M)
	M(i).Checked = 'off';
end


if strcmp(src.Text,'Stop')
	self.automate_action = crabsort.automateAction.none;
	return
end

if strcmp(src.Text,'Start')
	% OK, something is being started. so let's stop the timer
	stop(self.timer_handle)
	self.runAutomateAction();

	% add checkmark to chosen action
	M(strcmp({M.Text},src.Text)).Checked = 'on';


	return
end




self.auto_predict = false;




% set the automate action
possible_actions = (enumeration('crabsort.automateAction'));
possible_actions_str = {};
for i = 1:length(possible_actions)
	possible_actions_str{i} = strrep(char(possible_actions(i)),'_',' ');
end




self.automate_action = possible_actions(strcmp(src.Text,possible_actions_str));



% add checkmark to chosen action
M(strcmp({M.Text},src.Text)).Checked = 'on';

