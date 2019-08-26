
%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# displayStatus

**Syntax**

```
C.displayStatus()
```

**Description**

displays a message either on the main window
or in the title about what crabsort is doing
this is called by other methods to communicate
to the user about what crabsort is doign right now

%}



function displayStatus(self, msg, block_ux)

if self.verbosity > 9
	disp(mfilename)
end

if isempty(self.handles)
	return
end

if isa(msg,'MException')
	% format nicely
	err = msg;

	msg = {};
	msg{1} = err.message;

	for i = 1:length(err.stack)
		msg{end+1} = ['> ' err.stack(i).name];
	end
else
	msg = {'','','','','','','',msg};
end

if block_ux
    uistack(self.handles.popup,'top')
    self.handles.popup.Visible = 'on';
    self.handles.popup.String = msg;
    drawnow;


else
	disp('Not coded')
	if self.debug_mode
		keyboard
	else
		warning('Error in Display Status')
	end
end