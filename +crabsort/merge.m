% merges two data files of consolidated data together
% 
function data = merge(data1,data2)


if isempty(data1)
	data = data2;
	return
end	

fn1 = fieldnames(data1);
fn2 = fieldnames(data2);

onlyin1 = setdiff(fn1,fn2);
onlyin2 = setdiff(fn2,fn1);

for i = 1:length(onlyin1)
	this_field = onlyin1{i};


	for j = 1:length(data2)
		data2(j).(this_field) = NaN;
	end
end

for i = 1:length(onlyin2)
	this_field = onlyin2{i};


	for j = 1:length(data1)
		data1(j).(this_field) = NaN;
	end
end

data = [data1 data2];