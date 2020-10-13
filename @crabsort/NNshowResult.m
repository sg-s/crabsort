function NNshowResult(info)

arguments 
	info (1,1) struct 
end

if ~isempty(info.ValidationAccuracy)
	disp('ValidationAccuracy=')
	disp(info.ValidationAccuracy);
end
