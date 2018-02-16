function tf = doesChannelHaveAutomateInfo(self,channel)

if self.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

tf = false;

if length(self.common.automate_info) < channel
	return
end 

if length(self.common.automate_info(channel).operation) < 3
	return
end

tf = true;