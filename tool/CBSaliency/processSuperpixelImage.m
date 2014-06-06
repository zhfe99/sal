function imsegs = processSuperpixelImage(M)
% Creates the imsegs structure from a segmentation image.
%
% Input
%   M       - segmentation, h x w x nC
%
% Output
%   imsegs  - image segmentation data
%
% History
%   create  -  Derek Hoiem, 01-01-2005
%   modify  -  Feng Zhou (zhfe99@gmail.com), 06-22-2013

im = double(M);

% convert pixel value to region index
imsegs.imsize = size(im);
imsegs.imsize = imsegs.imsize(1 : 2);

% re-label
im = im(:, :, 1) + im(:, :, 2) * 256 + im(:, :, 3) * 256 ^ 2;
[gid, gn] = grp2idx(im(:));
imsegs.segimage = uint16(reshape(gid, imsegs.imsize));

% #regions
imsegs.nseg = length(gn);

% adjacecy & index of each region
imsegs = APPgetSpStats(imsegs);
