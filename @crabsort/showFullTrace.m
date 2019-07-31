%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


### showFullTrace(self,~,~)

**Syntax**

```
showFullTrace(self,~,~)
```

**Description**

This method shows the full extent of the data. 

%}

function showFullTrace(self,~,~)

if ~isempty(self.handles)
    if isfield(self.handles,'main_fig')
        set(self.handles.main_fig, 'pointer', 'watch')
        drawnow
    end
end

self.scroll([self.time(1) self.time(end)])

if ~isempty(self.handles)
    if isfield(self.handles,'main_fig')
        set(self.handles.main_fig, 'pointer', 'arrow')
        drawnow
    end
end