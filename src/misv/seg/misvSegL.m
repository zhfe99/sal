function wsSeg = misvSegL(src, wsVox, parSeg, varargin)
% Over-segment sequence into super-voxels.
%
% Input
%   src       -  hs src
%   parVox    -  voxel parameter
%   parSeg    -  segmentation parameter
%     th      -  threshold for merge similar segments, {0}
%     rat     -  ratio of maximum distance between region, {.2}
%     bins    -  bins, {[8 16 16 4]}
%   varargin
%     save option
%
% Output
%   wsSeg     -  segmentation result
%     prex    -  name
%     vdo     -  vdo path
%     mSeg    -  #segments
%     A       -  adjacency matrix, mSeg x mSeg
%     parVox  -  voxel parameter
%     parSeg  -  segmentation parameter
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 05-23-2013
%   modify    -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% function option
th = ps(parSeg, 'th', 0);
rat = ps(parSeg, 'rat', .2);
bins = ps(parSeg, 'bins', [8 16 16 4]); bins = bins(1 : 4);

% save option
subx = cellStr('th', th, 'rat', rat, 'bins', bins);
prex = cellStr(wsVox.prex, subx);
fold = sprintf('misv/%s/seg', src.tag);
[svL, vdopath] = psSv(varargin, ...
                      'prex', prex, ...
                      'subx', 'seg', ...
                      'fold', fold, ...
                      'type', 'fold');
matpath = sprintf('%s.mat', vdopath);

% load
if svL == 2 && exist(matpath, 'file')
    prInOut('misvSegL', 'old, %s', prex);
    wsSeg = matFld(matpath, 'wsSeg');
    wsSeg.vdo = vdopath;
    return;
end
prIn('misvSegL', 'new, %s', prex);
hTi = tic;

% streaming voxel -> global label
wsSeg0 = misvSegLM2L(src, wsVox, 'svL', 2);
[L0s, mSeg0, A0, keys] = stFld(wsSeg0, 'Ls', 'mSeg', 'A', 'keys');

% merge
wsSeg = misvSegLMerge(src, wsSeg0, bins, th, 'svL', 2);
[Ls, A, mSeg] = stFld(wsSeg, 'Ls', 'A', 'mSeg');

% vox in
hrVox = vdoRIn(wsVox.vdo, 'comp', 'img');
[nF, siz, fps, idx] = stFld(hrVox, 'nF', 'siz', 'fps', 'idx');

% save info.mat
reMkdir(vdopath);
pathform = 'frame_%04d.mat';
infopath = sprintf('%s/info.mat', vdopath);
save(infopath, 'nF', 'siz', 'fps', 'pathform', 'idx');

% save each frame
for iF = 1 : nF
    L0 = L0s(:, :, iF);
    L = Ls(:, :, iF);

    %% remove dis-connected region
    D = maskRegMax(L, mSeg0);
    S = single(D > rat);

    imgpath = sprintf(['%s/' pathform], vdopath, iF);
    save(imgpath, 'L0', 'L', 'S', 'D');
end

% store
wsSeg.prex = prex;
wsSeg.subx = subx;
wsSeg.parVox = wsVox.parVox;
wsSeg.parSeg = parSeg;
wsSeg.vdo = vdopath;
wsSeg.mSeg = mSeg;
wsSeg.mSeg0 = mSeg0;
wsSeg.A = A;
wsSeg.A0 = A0;
wsSeg.keys = keys;
wsSeg.rat = rat;
wsSeg.ti = toc(hTi);

% save
if svL > 0
    save(matpath, 'wsSeg');
end

prOut;
