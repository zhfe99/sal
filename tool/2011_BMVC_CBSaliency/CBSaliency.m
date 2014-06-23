function S = CBSaliency(F, Par, bins, th, epsilon)
% Region-based saliency algorithm.
%
% Input
%   F        -  image, h x w x nC
%   Par      -  segmentation parameter, n x 3
%   bins     -  #bin
%   th       -  threshold
%   epsilon  -  epsilon
%
% Output
%   S        -  salience, h x w
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 01-03-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 06-22-2013

% parameter for segmentation
if ~exist('Par', 'var')
    Par = [0.3, 350, 1200; ...
           0.4, 350, 1200; ...
           0.5, 350, 1200; ...
           0.6, 350, 1200; ...
           0.7, 350, 1200; ...
           0.8, 350, 1200; ...
           0.9, 350, 1200; ...
           1.0, 350, 1200];
end

% bin of color histogram
if ~exist('bins', 'var')
    bins = [8 16 16 4]; % CIE L*, a*, b*, and hue respectively
end

% threshold for merging adjacent superpixels
if ~exist('th', 'var')
    th = 0.2;
end

% the parameter used in Eqn.(2)
if ~exist('epsilon', 'var')
    epsilon = 0.1;
end

% first resize the image to a fixed size. The parameters may be more
% suitable on this scale

% dimension
h = size(F, 1);
w = size(F, 2);
r = 400 / max(w, h);
F = imresize(F, r);
F = im2double(F);

% quantize the image for color histogram generation
Q = computeQuantMatrix(F, bins);

S = zeros(size(F, 1), size(F, 2));
t1 = zeros(size(S));
t2 = zeros(size(S));

for ix = 1 : size(Par, 1)
    %% segment the image according to give parameters
    imsegs = im2superpixels(F, Par(ix, :));

    %% for each region, compute the color histogram
    L = imsegs.segimage;
    m = max(L(:));
    cLs = 1 : m;
    rh = computeRegionHist(Q, bins, L, cLs, m);

    %% merge adjacent regions if their color distance is small
    imsegs2 = mergeAdjacentRegions_fast(rh, imsegs, th);

    %% compute the region color histogram for merged regions
    L = imsegs2.segimage;
    m = max(L(:));
    cLs = 1 : m;
    rh2 = computeRegionHist(Q, bins, L, cLs, m);

    %% compute the color center for each region
    color_center = computeColorCenter(F, L, cLs, m);

    %% for each pixel, compute its color distance to the color center of the region which contains the pixel
    temp_color_weight = computeColorWeight(F, imsegs2.segimage, color_center, epsilon);

    %% compute one superpixel-scale saliency map based on context analysis
    temp_smap = computeOneScaleSmap(rh2, imsegs2.segimage, imsegs2.adjmat, m);

    t1 = t1 + temp_smap .* temp_color_weight;
    t2 = t2 + temp_color_weight;
end

% propogate the saliency value from region to pixel, which is
% weighted by the color distance, according to Eq.(2)
S = t1 ./ t2;

S = (S - min(S(:))) / (max(S(:)) - min(S(:)) + eps);
S = uint8(S * 255);
S = imresize(S, [h w]);
