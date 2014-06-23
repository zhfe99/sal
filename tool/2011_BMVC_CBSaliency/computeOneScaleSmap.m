function [sSegs, sHsts, sSpas, sAreas] = computeOneScaleSmap(D, A, areas, xDs, yDs, siz)
% Compute saliency for histogram.
%
% Input
%   D       -  histogram distance, mSeg x mSeg
%   A       -  adjacency matrix, mSeg x mSeg
%   areas   -  segment size, mSeg x 1
%   xDs     -  differency sum in X position, mSeg x 1
%   yDs     -  differency sum in Y position, mSeg x 1
%   siz     -  image size, 1 x 2
%
% Output
%   sSegs   -  salience of each segment, mSeg x 1
%   sHsts   -  histogram-based saliency, mSeg x 1
%   sSpas   -  spatial prior of each region, mSeg x 1
%   sAreas  -  weight of each area, mSeg x 1
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-03-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 07-02-2013

% dimension
h = siz(1);
w = siz(2);
mSeg = size(A, 1);

% set the diagonal = 1;
idx = sub2ind([mSeg, mSeg], 1 : mSeg, 1 : mSeg);
A(idx) = 1;

% spatial prior
sSpas = exp(-9 * (xDs ./ (areas + eps)) / w ^ 2 - 9 * (yDs ./ (areas + eps)) / h ^ 2);

% area weight
sAreas = areas / h / w / 0.52;
sAreas = 1 ./ (1 + sAreas .^ 11);

WArea = repmat(areas', [mSeg, 1]) .* double(A);
WArea = WArea ./ repmat(sum((WArea + eps), 2), [1, mSeg]);

% histogram-based distance
D1 = max(1 - D, eps);
SHst = -log(D1);
sHsts = sum(SHst .* WArea, 2);

% combine
% sSegs = sHsts .* sSpas .* sAreas;
sSegs = sHsts .* sSpas;
