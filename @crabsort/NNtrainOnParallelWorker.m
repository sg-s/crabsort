% this function does the actual heavy lifting in
% training the NN. meant to be run on a b/g worker

function NNtrainOnParallelWorker(NNdata,checkpoint_path)

try

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

    % we're going to name the network using the hash
    % of the spike detection parameters and 
    % what channels we're pulling it off of
    h1 = NNdata.sdp.hash;
    h2 = GetMD5([double(NNdata.other_nerves_control) double(NNdata.other_nerves)]);
    H = GetMD5([h1 h2]);

    NN_dump_file = [checkpoint_path filesep H '.mat'];

    if exist(NN_dump_file,'file') == 2
        disp('Loading existing file...')
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
    disp(NNdata.hash)

    [trainedNet, info] = trainNetwork(X_train,Y_train,layers,options);

    disp(['Saving to: ' NN_dump_file])
    save(NN_dump_file,'trainedNet','info')

catch err
    save([GetMD5(now) '.error'],'err')
end