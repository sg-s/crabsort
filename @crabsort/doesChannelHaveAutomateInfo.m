%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# doesChannelHaveAutomateInfo

**Syntax**

```
tf = doesChannelHaveAutomateInfo(self,channel)
```

**Description**

determines if a given channel has automate info

%}


function tf = doesChannelHaveAutomateInfo(self,channel)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end

assert(~isempty(channel),'channel must not be empty')


tf = false;



if isempty(self.common.automate_info)
	return
end 


fn = fieldnames(self.common.automate_info(channel));

for i = 1:length(fn)
	if isempty(self.common.automate_info(channel).(fn{i}))
		return
	end

end
tf = true;
return

