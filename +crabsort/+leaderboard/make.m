% makes the leaderboard

function make(look_here, nerve_name, neuron_name, window_size)

if isempty(look_here)
	look_here = pwd;
end

data = crabsort.leaderboard.measure(look_here);


all_exp_id = categorical(zeros(length(data),1));
all_best_snr = (NaN(length(data),1));
all_worst_snr = (NaN(length(data),1));
all_mean_snr = (NaN(length(data),1));

filelib.mkdir('~/Desktop/traces/')

for i = 1:length(data)
	

	try
		all_best_snr(i) = nanmax(data(i).SNR(data(i).nerve_name == nerve_name & data(i).neuron_name == neuron_name));
		all_worst_snr(i) = nanmin(data(i).SNR(data(i).nerve_name == nerve_name & data(i).neuron_name == neuron_name));
		all_mean_snr(i) = nanmean(data(i).SNR(data(i).nerve_name == nerve_name & data(i).neuron_name == neuron_name));
		exp_id = char(data(i).file_name(1));
		all_exp_id(i) = categorical({exp_id(1:max(strfind(exp_id,'_'))-1)});

	catch


	end

	if ~isnan(all_best_snr(i))
		this_file = data(i).file_name(find(data(i).SNR == all_best_snr(i)));
		this_file_path = data(i).path_name(find(data(i).SNR == all_best_snr(i)));


		C = crabsort(false);

		C.path_name = char(this_file_path);
		C.file_name = char(this_file);

		C.loadFile;

		raw_data = C.raw_data(:,strcmp(C.common.data_channel_names,nerve_name));

		

		try
			spiketimes = C.spikes.(nerve_name).(neuron_name);
			midpt = spiketimes(floor(length(spiketimes)/2));
			a = midpt - ceil(window_size/(2*C.dt));
			z = midpt + ceil(window_size/(2*C.dt));
			if a < 1
				a = 1;
			end
			if z > length(raw_data)
				z = length(raw_data);
			end

		catch
			a = 1;
			z = ceil(window_size/(C.dt));
		end



		temp.file_name = categorical(repmat(NaN,10,1));
		temp.nerve_name = categorical(repmat(NaN,10,1));
		temp.neuron_name = categorical(repmat(NaN,10,1));
		temp.SNR = (repmat(NaN,10,1));

		try
			if strcmp(C.path_name(end),filesep)
				temp = crabsort.analysis.measureSNR(dir([C.path_name C.file_name '.crabsort']),temp);
			else
				temp = crabsort.analysis.measureSNR(dir([C.path_name filesep C.file_name '.crabsort']),temp);
			end
			
		catch
			keyboard
		end


		figure('outerposition',[300 300 1200 450],'PaperUnits','points','PaperSize',[1200 450]); hold on
		plot(C.time(a:z), raw_data(a:z),'k')
		figlib.pretty('PlotLineWidth',1)
		axis off
		figlib.tight;


		saveas(gcf,['~/Desktop/traces/' strip(char(all_exp_id(i))) '.png'],'png');

		close all

	end
	
end


rm_this = all_exp_id == categorical(0);
all_exp_id(rm_this) = [];
all_best_snr(rm_this) = [];
all_worst_snr(rm_this) = [];
all_mean_snr(rm_this) = [];

% generate a HTML document with a table from this
template_file = [fileparts(which('crabsort.leaderboard.make')) filesep 'template.html'];
lines = filelib.read(template_file);


% insert nervename and neuronname
for i = 1:length(lines)
	if isempty(strfind(lines{i},'$NEURON_NAME'))
		continue
	end

	lines{i} = strrep(lines{i},'$NERVE_NAME', nerve_name);
	lines{i} = strrep(lines{i},'$NEURON_NAME', neuron_name);
	break
end

% prepare the lines to insert with the rows
row_lines = cell(length(all_exp_id),1);
row_template = '<tr><td>exp_id</td><td>best</td><td>worst</td><td>mean</td><td><img src = "./traces/exp_id.png"></td></tr>';


for i = 1:length(all_exp_id)
	this_line = row_template;
	this_line = strrep(this_line,'exp_id',char(all_exp_id(i)));
	this_line = strrep(this_line,'best',strlib.oval(log(all_best_snr(i))));
	this_line = strrep(this_line,'worst',strlib.oval(log(all_worst_snr(i))));
	this_line = strrep(this_line,'mean',strlib.oval(log(all_mean_snr(i))));
	row_lines{i} = this_line;
end


% figure out where to insert
insert_here = find(strcmp(lines,'$INSERT_ROWS_HERE'));
lines = [lines(1:insert_here-1); row_lines; lines(insert_here+1:end)];


filelib.write('~/Desktop/index.html',lines);

