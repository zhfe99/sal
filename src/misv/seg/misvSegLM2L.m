function wsSeg = misvSegLM2L(src, wsVox, varargin)
% Over-segment the HS sequence into super-voxels.
%
% Input
%   src       -  hs src
%   wsVox     -  voxel
%   varargin
%     save option
%
% Output
%   wsSeg     -  segmentation result
%     mSeg    -  #segments
%     keys    -  color key, mSeg x 1
%     A       -  adjacency matrix, mSeg x mSeg
%     vdo     -  vdo path
%     cL      -  level, 0 | 1 | ... | 20
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 05-23-2013
%   modify    -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% save option
prex = wsVox.prex;
fold = sprintf('misv/%s/seg', src.tag);
[svL, path] = psSv(varargin, ...
                      'prex', prex, ...
                      'subx', 'M2L', ...
                      'fold', fold);

% load
if svL == 2 && exist(path, 'file')
    prInOut('misvSegLM2L', 'old, %s', prex);
    wsSeg = matFld(path, 'wsSeg');
    return;
end
prIn('misvSegLM2L', 'new, %s', prex);

% vox in
hrVox = vdoRIn(wsVox.vdo, 'comp', 'img');

% video in
hrVdo = misvRIn(src);

% convert frame-based label to video-based one
[Ls, mSeg, keys] = vdoSegM2L(hrVox);

% adjaceny matrix
A = vdoSegL2A(Ls, mSeg);

% store
wsSeg.prex = prex;
wsSeg.Ls = Ls;
wsSeg.mSeg = mSeg;
wsSeg.A = A;
wsSeg.keys = keys;

% save
if svL > 0
    save(path, 'wsSeg');
end

prOut;