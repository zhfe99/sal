The source code implements the saliency computation algorithm described in published work [1]. Due to license issue, we cannot
provide the original code. The results of two implementations are nearly identical in our experiments. This code is provided for
research purpose only. Any problem, or just say that you like/dislike it, please contact jianghuaizu@gmail.com.

usage:
>> compile;                                                     % for the first time
>> matlabpool                                                   % for speeding up purpose
>> addpath('./segment');
>> image = imread('0_25_25057.png');
>> smap  = CBSaliency(image);                                   % using default parameters, see CBSaliency.m for details

To speedup saliency computation, one can use the MATLAB Parallel Computing Toolbox. For example, by typing matlabpool in the command
window. We use the segmentation algorithm developed by Pedro Felzenszwalb in [2] to generate superpixels.

References:
[1] Huaizu Jiang, Jingdong Wang, Zejian Yuan, Tie Liu, Nanning Zheng, Shipeng Li. Automatic Salient Object Segmentation Based on Context and Shape Prior. British Machine Vision Conference (BMVC) 2011.
[2] Pedro F. Felzenszwalb and Daniel P. Huttenlocher. Efficient Graph-Based Image Segmentation. IJCV, Volume 59, Number 2, September 2004.

AppGetSpStats.m, im2superpixels.m, processSuperpixelImage.m: These three files are from the Derek Hoiem.
computeQuantMatrx.m: This file is from Bogdan Alexe.
We only made small modifications.
