function wsSeg = misvSegLMerge(src, wsSeg0, bins, th, varargin)
% Merge the super-voxels.
%
% Input
%   src     -  hs src
%   wsSeg0  -  original segmentation
%   L0s     -  original label, h x w x nF
%   th      -  threshold for merge similar segments
%   bins    -  bins, [8 16 16 4]
%   varargin
%     save option
%
% Output
%   wsSeg   -  segmentation result
%     mSeg  -  #segments
%     keys  -  color key, mSeg x 1
%     A     -  adjacency matrix, mSeg x mSeg
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 05-23-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% save option
prex = cellStr(wsSeg0.prex, 'bins', bins, 'th', th);
fold = sprintf('misv/%s/seg', src.tag);
[svL, path] = psSv(varargin, ...
                   'prex', prex, ...
                   'subx', 'merge', ...
                   'fold', fold);

% load
if svL == 2 && exist(path, 'file')
    prInOut('misvSegLMerge', 'old, %s', prex);
    wsSeg = matFld(path, 'wsSeg');
    return;
end
prIn('misvSegLMerge', 'new, %s', prex);

% dimension
[L0s, A0, mSeg0] = stFld(wsSeg0, 'Ls', 'A', 'mSeg');
[h, w, nF] = size(L0s);
siz = [h, w];

% video in
hrVdo = misvRIn(src);

% histogram of each region
prCIn('histogram', nF, .1);
for iF = 1 : nF
    prC(iF);

    %% read frame
    F0 = vdoR(hrVdo, iF);
    F = imresize(F0, siz);

    %% read seg
    L0 = L0s(:, :, iF);

    %% quantize
    FQ = computeQuantMatrixImg(F, bins(1 : 4));
    HstFi = computeRegionHist_fast(FQ, double(L0), prod(bins(1 : 4)), mSeg0);

    %% store
    if iF == 1
        HstF = HstFi;
    else
        HstF = HstF + HstFi;
    end
end
prCOut(nF);

% compute distance
HstF = sparse(HstF);
D = computeHistDist(HstF, A0);
AD = D < th & D ~= 0;

% merge label
[Ls, A] = vdoSegMerge(L0s, A0, AD);
mSeg = size(A, 1);

% store
wsSeg.prex = prex;
wsSeg.Ls = Ls;
wsSeg.mSeg = mSeg;
wsSeg.A = A;
wsSeg.keys = wsSeg0.keys;

% save
if svL > 0
    save(path, 'wsSeg');
end

prOut;