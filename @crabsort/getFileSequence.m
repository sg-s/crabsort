%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# getFileSequence

**Syntax**

```
C.getFileSequence()
```

**Description**

gets a numerical sequence of the current file
in the list of all data files in the current folder

%}

function idx = getFileSequence(self)


if self.verbosity > 9
	disp(mfilename)
end

[~,~,ext]=fileparts(self.file_name);
allfiles = (dir([self.path_name '*' ext]));
idx = find(strcmp({allfiles.name},self.file_name));