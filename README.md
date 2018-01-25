# crabsort

[![GitHub last commit](https://img.shields.io/github/last-commit/sg-s/crabsort.svg)]()

![](https://user-images.githubusercontent.com/6005346/34060825-71d11a74-e1b3-11e7-9fcd-dba33f85561c.png)

`crabsort` is a framework written in MATLAB to help you sort spikes from multi-channel extracellular recordings. It is 

1. **highly modular** Almost everything is written as a plugin. `crabsort` is a [MATLAB class](https://www.mathworks.com/help/matlab/matlab_oop/classes-in-the-matlab-language.html), and plugins are methods defined within the class. 
2. **Accurate** On data with paired intracellular and extracellular recordings, `crabsort` was able to identify >99% of intracellular `LP`, `PD` & `LG` spikes in `lpn`, `pdn`, and `lgn`. 
3. **Data-agnostic** `crabsort` interfaces to your data through plugins, and `crabsort` doesn't care what your data format is.
4. **Bring-your-own-algorithm** `crabsort` splits up the spike sorting problem into two steps: dimensionality reduction and clustering. Every algorithm in either step is written as a plugin, and you can write your and drop it in, with *zero* modifications to the core code. For example, `crabsort` can use the amazing [mutli-core t-SNE algorithm](https://github.com/DmitryUlyanov/Multicore-TSNE) to embed spike shapes in two dimensions *very* rapidly. 

## Installation

`crabsort` is written in MATLAB, with a sprinkling of Python wrapper code. It should work on any OS that modern MATLAB runs on, but has only been tested on macOS Sierra with MATLAB R2017b. 

The best way to install `crabsort` is through my package manager: 

```
% copy and paste this code in your MATLAB prompt
urlwrite('http://srinivas.gs/install.m','install.m'); 
install -f sg-s/crabsort
install -f sg-s/srinivas.gs_mtools   % crabsort needs this 
install -f sg-s/Multicore-TSNE % fast t-sne embedding 
```

Or, if you have `git` installed:

````
git clone git@github.com:sg-s/crabsort.git
````

Don't forget to download, install and configure the other packages too. 


## Limitations and Scope

* `crabsort` is a tweaked version of an [earlier spikesorting package](https://github.com/sg-s/spikesort) that I wrote to sort spikes in extracellular recordings of *Drosophila* olfactory neurons. The changes I made here are specific to crabs and to the STG. 
* Currently, only `.ABF` and `.SMR` files are supported, though `crabsort`'s plugin architecture makes adding support for a new file format trivial. 
* No support for manually adding or removing spikes. 

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
