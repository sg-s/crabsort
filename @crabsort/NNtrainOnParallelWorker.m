% this function does the actual heavy lifting in
% training the NN. meant to be run on a b/g worker

function NNtrainOnParallelWorker(NNdata,checkpoint_path)



X = NNdata.raw_data;
Y = NNdata.label_idx;

% split into training and validation
R = rand(size(X,2),1)>.5;


X_train = X(:,R);
Y_train = Y(R);

X_validate = X(:,~R);
Y_validate = Y(~R);


% make layers for the neural net
SZ = size(X_train,1);


H = NNdata.hash;
NN_dump_file = [checkpoint_path filesep H '.mat'];


if exist(NN_dump_file,'file') == 7
    % load
    load(NN_dump_file)
    layers = trainedNet.Layers;
    
else
    disp('Making new network...')
    layers = crabsort.NNmake(SZ,length(unique(Y_train)));
end




N_train = size(X_train,2);
N_validate = size(X_validate,2);
X_train = reshape(X_train,SZ,1,1,N_train);
X_validate = reshape(X_validate,SZ,1,1,N_validate);

Y_train = categorical(Y_train(:));
Y_validate = categorical(Y_validate(:));

options = trainingOptions('sgdm',...
    'LearnRateSchedule','piecewise',...
    'Shuffle','every-epoch',...
    'LearnRateDropFactor',0.2,...
    'LearnRateDropPeriod',10,...
    'MaxEpochs',30,...
    'MiniBatchSize',32,...
    'ValidationData',{X_validate, Y_validate},...
    'ValidationFrequency',5,...
    'Plots','none',...
    'Verbose',0,...
    'ExecutionEnvironment','cpu',...
    'OutputFcn',@crabsort.NNshowResult);


disp('hash of data training on = ')
disp(NNdata.fullHash)

[trainedNet, info] = trainNetwork(X_train,Y_train,layers,options);
save(NN_dump_file,'trainedNet','info')