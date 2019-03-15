%{ 
                _                    _   
  ___ _ __ __ _| |__  ___  ___  _ __| |_ 
 / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
| (__| | | (_| | |_) \__ \ (_) | |  | |_ 
 \___|_|  \__,_|_.__/|___/\___/|_|   \__|
                                         


# NNmake

**Syntax**

```
crabsort.NNmake(input_size,n_classes)
```

**Description**

a static method of crabsort that
makes a convolutional neural network

%}

function layers = NNmake(input_size, n_classes)



layers = [
    imageInputLayer([input_size 1 1],'Normalization','none')
    
    % convolution2dLayer([20, 1],60,'NumChannels',1)
    % batchNormalizationLayer
    % reluLayer

    % dropoutLayer(.5)
    
    % maxPooling2dLayer([2 1],'Stride',2)
    
    % convolution2dLayer([10 1],40,'NumChannels',1)
    % batchNormalizationLayer
    % reluLayer
    
    % maxPooling2dLayer([2 1],'Stride',2)

    % dropoutLayer(.25)


    fullyConnectedLayer(200)
    reluLayer

    fullyConnectedLayer(200)
    reluLayer
    dropoutLayer(.1)


    fullyConnectedLayer(n_classes)
    softmaxLayer
    classificationLayer];

