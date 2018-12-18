

function NNtrainAndSave(self,X_train,Y_train,layers,options, channel)

[trainedNet, info] = trainNetwork(X_train,Y_train,layers,options);


save_here = [self.path_name 'network' filesep self.common.data_channel_names{channel} filesep 'trained_network.mat'];


save(save_here,'trainedNet','info')
