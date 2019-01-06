%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# canDetectSpikes

**Syntax**

```
tf = canDetectSpikes(self,channel)
```

**Description**

determines if NNdata has enough data to know
what a spike is, i.e., is the spike_prom, etc
set? 

%}


function tf = canDetectSpikes(self)


tf = false;

props = properties(self.spd);
for i = 1:length(props)
	if isempty(self.spd.(props{i}))
		return
	end
end

tf = true;
