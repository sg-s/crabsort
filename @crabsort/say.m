%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


### say

**Syntax**

```
say(self,msg)
```

**Description**

Updates the figure name in the main GUI to display a message. That message
will automatically get erased due to the NNtimer

%}
function say(self,msg)

self.handles.main_fig.Name = [self.file_name ' -- ' msg];
self.handles.main_fig.UserData = now;
drawnow limitrate