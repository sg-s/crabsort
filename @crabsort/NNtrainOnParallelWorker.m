% this function does the actual heavy lifting in
% training the NN. meant to be run on a b/g worker

function NNtrainOnParallelWorker(job_file_location, worker_idx)




while true

    pause(2)

    % check the job_file_location
    allfiles = dir([job_file_location filesep  mat2str(worker_idx) '_*.job']);

    if isempty(allfiles)
        disp('No jobs, aborting...')
        continue
    end

    use_this = 1;
    us = strfind(allfiles(1).name,'_');
    most_recent_ts = datenum(strrep(allfiles(1).name(us(1)+1:end-4),'_',':'));

    if length(allfiles) > 1
        

        for i = 2:length(allfiles)
            us = strfind(allfiles(i).name,'_');
            this_ts = datenum(strrep(allfiles(i).name(us(1)+1:end-4),'_',':'));
            if this_ts > most_recent_ts
                most_recent_ts = this_ts;
                use_this = i;
            end

        end
    end

    load([allfiles(use_this).folder filesep allfiles(use_this).name],'-mat')

    % delete all job files since we don't want to run on old ones
    for i = 1:length(allfiles)
        delete([allfiles(i).folder filesep allfiles(i).name])
    end
    


    X = network_data.X;
    Y = network_data.Y;

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
    
    checkpoint_path = network_data.checkpoint_path;
    H = network_data.hash;
    NN_dump_file = [checkpoint_path filesep H '.mat'];


    if exist(NN_dump_file,'file') == 2
        disp('Loading existing network...')
        try
            load(NN_dump_file)
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
        'MaxEpochs',2,...
        'MiniBatchSize',32,...
        'ValidationData',{X_validate, Y_validate},...
        'ValidationFrequency',5,...
        'Plots','none',...
        'Verbose',0,...
        'ExecutionEnvironment','cpu',...
        'OutputFcn',@crabsort.NNshowResult);


    disp('timestamp of data training on = ')
    disp(datestr(most_recent_ts))

    [trainedNet, info] = trainNetwork(X_train,Y_train,layers,options);

    disp(['Saving to: ' NN_dump_file])
    save(NN_dump_file,'trainedNet','info')
    


end





