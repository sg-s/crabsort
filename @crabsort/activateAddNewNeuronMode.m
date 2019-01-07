%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# activateAddNewNeuronMode

**Syntax**

```
activateAddNewNeuronMode(self,~,~)
```

**Description**

This method is a callback function of new_spike_type
and activates the new spike mode in manual override

%}


function activateAddNewNeuronMode(self,~,~)

self.handles.mode_new_spike.Value = 1;