function anMovSal(src, wsSmp, wsSal, varargin)
% Animate segmentation for high-speed video.
%
% Input
%   src      -  source
%   wsSeg    -  segmentation
%   sSegs    -  segment's saliency, 1 x mSeg
%   varargin
%     fig    -  figure number, {2}
%     sizMa  -  maximum figure size, [1000, 1000]
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 05-24-2013
%   modify   -  Feng Zhou (zhfe99@gmail.com), 06-23-2014

% function option
fig = ps(varargin, 'fig', 2);
sizMa = ps(varargin, 'sizMa', [700 1200]);
ftSiz = ps(varargin, 'ftSiz', 15);
ftCl = ps(varargin, 'ftCl', [0 0 0]);
ftBkCl = ps(varargin, 'ftBkCl', [1 1 1]);

% save option
prex = src.tag;
prIn('anMovSal', 'new, %s', prex);

% video in
hrVdo = movRIn(src);

% sampling
[nF, pFs] = stFld(wsSmp, 'nF', 'pFs');

% sal in
hrSal = vdoRIn(wsSal.vdo, 'comp', 'mat');
siz = stFld(hrSal, 'siz');
R0 = stFld(wsSal, 'R');
R = ranConv(2000, 'both', R0);

% figure
rows = 1; cols = 2;
[Ax, figSiz] = iniAx(fig, rows, cols, siz([1 2]) .* [rows cols], 'hGap', 0, 'wGap', 0, 'sizMa', sizMa);
AxT = iniAxIn(Ax, [0.4, 0.85, .2, 0.1]);

% plot frame
prCIn('frame', nF, .1);
for iF = 1 : nF
    prC(iF);
    pF = pFs(iF);

    %% read video
    F0 = vdoR(hrVdo, pF);
    F = imresize(F0, siz);

    %% read saliency
    mat = vdoR(hrSal, iF);
    S = stFld(mat, 'S');
    S = ranNor(S, R(:, iF));
    
    %% overlay
    FS = heatmap_overlay(F, S);

    %% show
    if iF == 1
        hFS = shImg(FS, 'ax', Ax{1, 1});
        hS = shImg(S, 'ax', Ax{1, 2});
        shStr('Original', 'ax', AxT{1, 1}, 'ftCl', ftCl, 'ftSiz', ftSiz', 'ftBkCl', ftBkCl);
        shStr('Saliency', 'ax', AxT{1, 2}, 'ftCl', ftCl, 'ftSiz', ftSiz', 'ftBkCl', ftBkCl);

    else
        shImgUpd(hFS, FS);
        shImgUpd(hS, S);
    end

    pause(.1);
end
prCOut(nF);

prOut;
