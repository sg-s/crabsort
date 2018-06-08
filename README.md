# 🦀 crabsort

[![GitHub last commit](https://img.shields.io/github/last-commit/sg-s/crabsort.svg)]()


`crabsort` is a framework written in MATLAB to help you sort spikes from multi-channel extracellular recordings. It is 

1. **highly modular** Almost everything is written as a plugin. `crabsort` is a [MATLAB class](https://www.mathworks.com/help/matlab/matlab_oop/classes-in-the-matlab-language.html), and plugins are methods defined within the class. 
2. **Accurate** On data with paired intracellular and extracellular recordings, `crabsort` was able to identify >99% of intracellular `LP`, `PD` & `LG` spikes in `lpn`, `pdn`, and `lgn`. 
3. **Data-agnostic** `crabsort` interfaces to your data through plugins, and `crabsort` doesn't care what your data format is.
4. **Bring-your-own-algorithm** `crabsort` splits up the spike sorting problem into two steps: dimensionality reduction and clustering. Every algorithm in either step is written as a plugin, and you can write your and drop it in, with *zero* modifications to the core code. For example, `crabsort` can use the amazing [mutli-core t-SNE algorithm](https://github.com/DmitryUlyanov/Multicore-TSNE) to embed spike shapes in two dimensions with great alacrity. 
5. **Fully-automated** `crabsort` offers powerful automation features, and is full script-able. Fully automated luxury gay space crabsort for the win.
6. **Tensorflow-powered** `crabsort` can use [tensorflow](https://www.tensorflow.org/), Google's scarily powerful deep learning toolbox, to learn from sorted data and sort new data automatically. 

## Features

### Real-time live spike detection using peak prominence 

![](https://user-images.githubusercontent.com/6005346/36066160-3e672d94-0e73-11e8-917e-2838e574955d.gif)

Find spikes with a given prominence, and see the spikes you get live for a chosen prominence. Immediate, live detection works no matter how big your dataset is. 

### Customize the features of the spike you care about 

Some spikes can be sorted using just the spike shape. Others need information on other spikes in other channels. Choose what's best for the problem, and `crabsort` will remember this on a per-channel basis and automatically use the right features.

### Use the best dimensionality reduction algorithm for the task

![](https://user-images.githubusercontent.com/6005346/36075850-5865b922-0f22-11e8-82bc-dbcae7cda8c7.png)

Use principal components, which is fast but not very powerful. Or use t-SNE, which can segment data far more effectively. `crabsort` uses a [multi-core implementation of t-SNE](https://github.com/sg-s/Multicore-TSNE) which is **much** faster than anything else out there. 

### Interactive clustering in 2D

### Manual correction 

![](https://user-images.githubusercontent.com/6005346/36075988-5bd2f6fe-0f24-11e8-9703-76b5c46ff341.gif)

One-click manual override allows you to add or remove spikes at whim. 

### Multi-pass sorting 

The spike-sorting problem too hard to solve in one pass? No problem -- make multiple passes through the same data, using arbitrary combinations of dimensionality reduction and clustering algorithms. 

### Automate all the things

`crabsort` can watch -- and reproduce -- every action you make on novel data. So sorting a massive dataset can be as simple as performing some actions once, on one file, and asking `crabsort` to repeat it for every file. No programming required. 

### Machine learning built-in 

|  |  |
| --- | --- | 
| ![](https://www.tensorflow.org/_static/images/tensorflow/logo.png) | `crabsort` can use Google's powerful tensorflow library to train models and to use it to predict and classify spikes in new data. `crabsort` ships with a convolutional neural network that seems to work well for spikes. 

## Installation

`crabsort` is written in MATLAB, with a sprinkling of Python wrapper code. It should work on any OS that modern MATLAB runs on, and has been tested on macOS Sierra with MATLAB R2017b and Ubuntu with MATLAB R2017a. 

The best way to install `crabsort` is through my package manager: 

```
% copy and paste this code in your MATLAB prompt
urlwrite('https://srinivas.gs/install.m','install.m'); 
install -f sg-s/crabsort
install -f sg-s/srinivas.gs_mtools   % crabsort needs this 
install -f sg-s/Multicore-TSNE % fast t-sne embedding 
install -f sg-s/condalab % switch between python envs
```

Or, if you have `git` installed:

````
git clone git@github.com:sg-s/crabsort.git
````

Don't forget to download, install and configure the other packages too. 

### Dependencies 

#### Anaconda 

`crabsort` uses some python libraries that are assumed to be installed using [Anaconda](https://www.anaconda.com/). Make sure you install anaconda and then install python packages using conda environments! 

#### Multicore-tSNE

[Read the docs](https://github.com/sg-s/Multicore-TSNE) to make sure your installation works, and your paths are correct. 

#### Tensorflow

Make a `conda` environment for yourself and install tensorflow in that container. Follow the instructions on [this page](https://www.tensorflow.org/install/install_mac#installing_with_anaconda) under the "Anaconda Install" section. Make sure you install the Python 3 version -- it's 2018. 

For clarity, I've listed the steps I went through to install Tensorflow. You should do something similar:

```bash
# assuming conda is installed

# create a new environment called "tensorflow"
# and install pip in it
conda create -n tensorflow pip 

# switch to this environment 
source activate tensorflow 

# install tensorflow 
pip install tensorflow

# install h5py
pip install h5py

```

#### h5py

You need to install this tool in **every** python environment you are using. 

```bash
# install h5py in your tensorflow env
source activate tensorflow
pip install h5py

# install h5py in your mctsne env
source activate mctsne
pip install h5py
``` 

## Architecture


`crabsort` is built around a plugin architecture for the three most important things it does: 

* Data handling
* Dimensionality reduction of spike shapes
* Clustering 

### Writing your own plugins

Writing your own plugins is really easy: plugins are methods that you can simply drop into the `crabsort` classdef folder (`@crabsort`), and `crabsort` automatically figures out which methods are plugins (see naming convention below)

#### Naming and Plugin declaration
Plugins can be named whatever you want, though you are encouraged to use `camelCase` for all methods. The first three lines of every plugin should conform to the following convention:

```matlab
% crabsort plugin
% plugin_type = 'dim-red';
% plugin_dimension = 2; 
% 

```

The first line identifies the method as a `crabsort` plugin, and the second line determines the type of plugin it is. Currently, plugins can be of several types:

1. `dim-red`
2. `cluster`
3. `read-data`
4. `load-file`

If you are writing a `read-data`or `load-file` plugin, the convention for the first three lines is as follows:

```matlab
% crabsort plugin
% plugin_type = 'load-file';
% data_extension = 'abf'
% 
```

`data_extension` identifies the extension that `crabsort` binds that plugin to. 


`plot-spikes` plugins are expected to read all spikes in that data file, and make a raster or a firing rate plot, with appropriate labels for each trial and paradigm set. 

# License 

[GPL v3](http://gplv3.fsf.org/)

If you plan to use `crabsort` for a publication, please [write to me](http://srinivas.gs/#contact) for appropriate citation. 
