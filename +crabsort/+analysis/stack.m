function sdata = stack(data, options)

stack_id = 0;

fn = fieldnames(data);

sdata = struct;

for j = 1:length(fn)
	sdata.(fn{j}) = [];
end



for i = 1:length(data)

	if data(i).time_offset == 0
		stack_id = stack_id + 1;



		for j = 1:length(fn)
			sdata(stack_id).(fn{j}) = [];
		end

	end



	% add to the current stack 
	corelib.textbar(i,length(data))
	for j = 1:length(fn)
		if any(strcmp(fn{j},options.neurons))
			sdata(stack_id).(fn{j}) = [sdata(stack_id).(fn{j}); data(i).time_offset+data(i).(fn{j})];
		elseif strcmp(fn{j},'T')
		elseif strcmp(fn{j},'time_offset')
		elseif strcmp(fn{j},'experiment_idx')
			sdata(stack_id).experiment_idx = data(i).experiment_idx;
		else



			% check size
			this_variable = data(i).(fn{j});
			if isscalar(this_variable)
				if isa(this_variable,'categorical')
					this_variable = repmat(this_variable,length(data(i).mask),1);
				else
					this_variable = this_variable*(data(i).mask*0 + 1);
				end

			elseif length(this_variable) ~= length(data(i).mask)
				% this variable is neither a scalar nor is it as long as the mask
				% it's something else, so we need to extrapolate from what we have
				this_variable = interp1(linspace(0,1,length(this_variable)),this_variable, linspace(0,1,length(data(i).mask)));

				this_variable = this_variable(:);

			end

			sdata(stack_id).(fn{j}) = [sdata(stack_id).(fn{j}); this_variable];

		end
	end


end


for i = 1:stack_id
	sdata(i).time_offset = (1:length(sdata(i).mask))*options.dt;
end