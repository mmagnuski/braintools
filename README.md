# braintools
Heterogeneous pack of tools helpful in analysis of brain signals.

### Installation
Clone or download braintools to some cosy place on your computer. Then add path to the main folder (and save) using:
```matlab
pathtool
```
or simply by executing:
```matlab
pth = 'D:\path\to\braintools';
addpath(pth);
```
  
Then you activate braintools by writing:
```matlab
braintools
```
This command adds paths to subdirectories of braintools. If you do not want to initialize braintools every time you open a new matlab session you can also save the current search path:
```matlab
savepath
```

### Examples
- [topo_scrapper](examples/topo_scrapper.md)
