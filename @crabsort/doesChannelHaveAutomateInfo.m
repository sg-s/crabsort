function tf = doesChannelHaveAutomateInfo(self,channel)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end

assert(~isempty(channel),'channel must not be empty')


tf = false;

if length(self.common.automate_info) < channel
	return
end 

if length(self.common.automate_info(channel).operation) < 3
	return
end

tf = true;