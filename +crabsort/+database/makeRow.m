function T = makeRow()

% configure the database table
ExpName = {''};
experimenter = {''};
TempCached = {''};
TempChannelExists = {''};
DataMissing = {''};
NumPDSpikes = -1;
NumLPSpikes = -1;
SortProgress = -1;
PDLPUsable = {''};
Comments = {'none'};


T = table(ExpName,experimenter,TempCached,TempChannelExists,DataMissing,NumPDSpikes,NumLPSpikes,SortProgress,PDLPUsable,Comments);
