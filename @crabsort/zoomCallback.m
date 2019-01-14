%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


### zoomCallback

**Syntax**

```
zoomCallback(self,~,event)
```

**Description**

This method is executed when the user zooms in and out of 
any plot in the main figure

%}

function zoomCallback(self,~,event)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


idx = find(self.handles.ax.ax == event.Axes);


% change the XLim of all the other axes to match this
for i = 1:length(self.handles.ax.ax)
	if i == idx
		continue
	end


	self.handles.ax.ax(i).XLim = self.handles.ax.ax(idx).XLim;


end 


self.scroll(self.handles.ax.ax(idx).XLim)