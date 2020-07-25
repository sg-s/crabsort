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
lpn = 0;
lgn = 0;
pdn = 0;
lvn = 0;
pyn = 0;
LP = 0;
PD = 0;
decentralized = 0;

T = table(ExpName,experimenter,lpn,pdn,lgn,lvn,pyn,PD,LP,TempCached,TempChannelExists,decentralized, DataMissing,NumPDSpikes,NumLPSpikes,SortProgress,PDLPUsable,Comments);
