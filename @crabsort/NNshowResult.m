function NNshowResult(info)

try
	if ~isempty(info.ValidationAccuracy)
		disp('ValidationAccuracy=')
		disp(info.ValidationAccuracy);
	end
catch

end