%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# NNmakeCheckpointDirs

**Syntax**

```
C.NNmakeCheckpointDirs()
```

**Description**

makes folders to contain checkpoints (saved networks) 
for the neural network, if needed. if these folders
already exist, nothing is done. 

%}

function NNmakeCheckpointDirs(self)


if exist([self.path_name 'network'],'dir')  ~= 7

	mkdir([self.path_name 'network'])


end

for i = 1:self.n_channels
	this_nerve = self.common.data_channel_names{i};
	if isempty(this_nerve)
		continue
	end

	if exist([self.path_name 'network' filesep this_nerve]) ~= 7
		mkdir([self.path_name 'network' filesep this_nerve])
	end


end