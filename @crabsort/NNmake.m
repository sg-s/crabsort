function layers = NNmake(self, input_size, n_classes)


layers = [
    imageInputLayer([input_size 1 1],'Normalization','none')
    
    convolution2dLayer([30, 1],40,'NumChannels',1)

    batchNormalizationLayer
    reluLayer

    dropoutLayer(.2)
    
    maxPooling2dLayer([2 1],'Stride',2)
    
    convolution2dLayer([30 1],10,'NumChannels',1)
    %batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer([2 1],'Stride',2)

    dropoutLayer(.25)

    fullyConnectedLayer(n_classes)
    softmaxLayer
    classificationLayer];

