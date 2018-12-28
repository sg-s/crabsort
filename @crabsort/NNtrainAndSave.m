function NNtrainAndSave(self,X_train,Y_train,layers,options, channel, H)

[trainedNet, info] = trainNetwork(X_train,Y_train,layers,options);


save_here = [self.path_name 'network' filesep self.common.data_channel_names{channel} filesep H '.mat'];


save(save_here,'trainedNet','info')