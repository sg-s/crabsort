function NNshowResult(self,info)

disp('iteration= ')
disp(info.Iteration)

if ~isempty(info.ValidationAccuracy)
	disp('ValidationAccuracy=')
	disp(info.ValidationAccuracy);
end
