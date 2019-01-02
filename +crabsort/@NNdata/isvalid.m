%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# isvalid

**Syntax**

```
tf = isvalid(self,channel)
```

**Description**

determines if NNdata has enough data to know
what a spike is, i.e., is the spike_prom, etc
set? 

%}


function tf = isvalid(self)


tf = false;

if isempty(self.spike_prom)
	return
end

if isempty(self.spike_sign)
	return
end

if isempty(self.other_nerves_control)
	return
end

tf = true;
