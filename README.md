Introduction
============

This page contains software and instructions for
[Space-Time Saliency](http://www.f-zhou.com/tm.html) [1].

[1] F. Zhou, F. de la Torre, and J. K. Hodgins, "Aligned cluster analysis for temporal segmentation of human motion," in International Conference on Automatic Face and Gesture Recognition (FG), 2008.

Installation
============

1. unzip `sal.zip` to your folder;
2. Run `make.m` to compile all C++ files;
3. Run `addPath.m` to add sub-directories into the path of Matlab.
4. Run `demoSal.m` file.


Instructions
============
The package of `sal.zip` contains the following files and folders:
- `./data`: This folder contains a video sequence as example.
- `./core`: This folder contains the main implementation of the space-time and HACA.
- `./lib`: This folder contains some necessary library functions.
- `./make.m`: Matlab makefile for C++ code.
- `./addPath.m`: Adds the sub-directories into the path of Matlab.
- `./demoSal.m`: A demo file for generating visualizing the saliency for a video.

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

    @inproceedings{Zhou_2008_6155,
    author    = {Feng Zhou and Fernando De la Torre and Jessica K. Hodgins},
    title     = {Aligned Cluster Analysis for Temporal Segmentation of Human Motion},
    booktitle = {IEEE Conference on Automatic Face and Gestures Recognition (FG)},
    month     = {September},
    year      = {2008},
    }

If you have any question, please feel free to contact Feng Zhou (zhfe99@gmail.com).
