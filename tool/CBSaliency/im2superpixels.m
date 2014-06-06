function [imsegs, M] = im2superpixels(im, para)
% Compute super-piexls from images.
%
% Input
%   im      -  image
%   para    -  parameter, 1 x 3
%
% Output
%   imsegs  -  segmentation
%   M       -  segmentation, h x w x nC
%
% History
%   create  -  Derek Hoiem, 01-01-2005
%   modify  -  Feng Zhou (zhfe99@gmail.com), 07-28-2013

% default parameter
if nargin == 1
    para = [0.8 100 100];
end

% convert
if strcmp(class(im), 'uint8')
    im = double(im);
end

% normalize
if max(im(:)) < 10
    im = double(im * 255);
end

% core algorithm
M = mexSegment(im, para(1), para(2), int32(para(3)));
% M = imgSegGb(im, para(1), para(2), para(3));
% equal('M', M, M2);

% post-processing
imsegs = processSuperpixelImage(M);
