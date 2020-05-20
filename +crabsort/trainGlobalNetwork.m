% this function does the actual heavy lifting in
% training the NN. meant to be run on a b/g worker

function trainGlobalNetwork(nerve_name, SpikeSign)


% load all the data for this nerve


allfiles = dir([fileparts(fileparts(which('crabsort'))) filesep 'global-network' filesep nerve_name '_' mat2str(SpikeSign) '*.mat']);

if length(allfiles) == 0 
    disp('No files found, nothing to do...')
    return
end


all_X = [];
all_Y = [];

for i = 1:length(allfiles)
    load([allfiles(i).folder filesep allfiles(i).name])
    all_X = [all_X X];
    all_Y = [all_Y; Y];

end


X = all_X;
Y = all_Y;

disp([mat2str(length(Y)) ' samples in training data'])


% split into training and validation
R = rand(size(X,2),1)>.5;




X_train = X(:,R);
Y_train = Y(R);

X_validate = X(:,~R);
Y_validate = Y(~R);



% make layers for the neural net
SZ = size(X_train,1);


NN_dump_file = [fileparts(fileparts(which('crabsort'))) filesep 'global-network' filesep nerve_name '_' mat2str(SpikeSign) '.network'];


if exist(NN_dump_file,'file') == 2
    disp('Loading existing network...')
    try
        load(NN_dump_file,'-mat')
    catch
        % for whatever reason, the file exists, but we can't load it
        % in this case the best thing to do is nuke this file and abort
        delete(NN_dump_file)
        return
    end
    layers = trainedNet.Layers;
    
else
    disp('Making new network...')
    layers = crabsort.NNmake(SZ,length(unique(Y_train)));
end




N_train = size(X_train,2);
N_validate = size(X_validate,2);
X_train = reshape(X_train,SZ,1,1,N_train);
X_validate = reshape(X_validate,SZ,1,1,N_validate);

Y_train = (Y_train(:));
Y_validate = (Y_validate(:));

options = trainingOptions('sgdm',...
    'LearnRateSchedule','piecewise',...
    'Shuffle','every-epoch',...
    'LearnRateDropFactor',0.2,...
    'LearnRateDropPeriod',10,...
    'MaxEpochs',5,...
    'MiniBatchSize',32,...
    'ValidationData',{X_validate, Y_validate},...
    'ValidationFrequency',5,...
    'Plots','none',...
    'VerboseFrequency',100,...
    'ExecutionEnvironment','cpu');



[trainedNet, info] = trainNetwork(X_train,Y_train,layers,options);

disp(['Saving to: ' NN_dump_file])
save(NN_dump_file,'trainedNet','info')



