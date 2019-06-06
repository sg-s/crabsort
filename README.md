# 🦀 crabsort

[![GitHub last commit](https://img.shields.io/github/last-commit/sg-s/crabsort.svg)]()


# Installation

## Using a MATLAB toolbox

The simplest way to install `crabsort` is to [download this toolbox](https://github.com/sg-s/crabsort/releases/latest). Drag it onto your MATLAB workspace, and it should automatically install itself. 


## Using git

Clone these repos:

```
# bash
git clone https://github.com/sg-s/crabsort
git clone https://github.com/sg-s/puppeteer
git clone https://github.com/sg-s/srinivas.gs_mtools
```

and add the all to your MATLAB path. 

## Updating and uninstalling

`crabsort` supports built-in methods to upgrade and update:

```
% matlab
crabsort.update
crabsort.uninstall
```


# Usage

[more detailed docs coming soon...]

## Keyboard actions

| Key | Action |
| ---------- | ---------- |
| `a` | Scroll to beginning of file |
| `z` | Scroll to end of file |
| `Spacebar` | Jump to next uncertain spike (as predicted by Neural Network) |
| `g` | generate data for Neural network | 
| `⇧ + ↑` | jump to the weirdest spike |
| `⇧ + ↓` | jump to a next less weird spike |
| `p` | Predict spikes using Neural network |
| `r` | reset zoom | 
| `0` | Set channel as having no spikes |



# License 

[GPL v3](http://gplv3.fsf.org/)

If you plan to use `crabsort` for a publication, please [write to me](http://srinivas.gs/#contact) for appropriate citation. 
