

function NNtrainAndSave(self,X_train,Y_train,layers, options)

[trainedNet, info] = trainNetwork(X_train,Y_train,layers,options);


save_here = [self.path_name 'network' filesep self.common.data_channel_names{self.channel_to_work_with} filesep 'trained_network.mat'];

save(save_here,'trainedNet')
