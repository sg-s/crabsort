
function NNupdateAutoPredict(self,src,value)


if strcmp(src.Checked,'on')
	src.Checked = 'off';
	self.auto_predict = false;
else
	src.Checked = 'on';
	self.auto_predict = true;
end
