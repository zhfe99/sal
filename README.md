Introduction
============

This page contains software and instructions for
[Space-Time Saliency](http://www.f-zhou.com/tm.html) [1].

Installation
============

The code is divided into two parts: **Part 1** is hosted on Microsoft's
website, containing the core implementation of the space-time saliency
method; **Part 2** is hosted on GitHub, containing the auxiliary files
(including library, toolbox, a video and a demo) to use this code. You
need to download both parts and unzip them in the same folder (eg,
`./sal`).

1. set `sal` to your current folder in Matlab;
2. Run `make.m` in Matlab to compile all C++ files;
3. Run `addPath.m` to add sub-directories into the path of Matlab.
4. Run `demoSal.m` file.


Instructions
============

The package contains the following files and folders:
- `./data`: This folder contains a video sequence as example.
- `./core`: This folder contains the main implementation of the space-time saliency algorithm.
- `./src`: This folder contains a wrapper of the space-time saliency for any video input.
- `./lib`: This folder contains some necessary library functions.
- `./make.m`: Matlab makefile for C++ code.
- `./addPath.m`: Adds the sub-directories into the path of Matlab.
- `./demoSal.m`: A demo file for generating and visualizing the saliency for a video input.

References
==========

[1] [F. Zhou](http://www.f-zhou.com),
[S.-B. Kang](http://research.microsoft.com/en-us/people/sbkang/),
and
[M. Cohen](http://research.microsoft.com/en-us/um/people/cohen/),
"Time-Mapping Using Space-Time Saliency," in IEEE Conference on
Computer Vision and Pattern Recognition (CVPR), 2014

Copyright
==========

This software is free for use in research projects. If you publish
results obtained using this software, please use this citation.

    @inproceedings{ZhouKC14,
    author    = {F. Zhou and S.-B. Kang and M. Cohen},
    title     = {Time-Mapping Using Space-Time Saliency},
    booktitle = {IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
    year      = {2014},
    }

If you have any question, please feel free to contact Feng Zhou (zhfe99@gmail.com).
