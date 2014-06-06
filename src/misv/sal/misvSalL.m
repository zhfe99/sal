function wsSal = misvSalL(src, wsSmp, wsFlow, wsAcc, wsBk, wsSeg, parSal, varargin)
% Combine salience of high-speed video.
%
% Input
%   src      -  source
%   wsSmp    -  sampling
%   wsFlow   -  optical flow
%   wsAcc    -  acceleration
%   wsBk     -  background
%   wsSeg    -  video segmentation
%   parSal   -  parameter of salience
%     bins   -  bins for quantatize appearance and flow, {[8 16 16 4 8 9]}
%     wS     -  window for cumulating histogram for computing saliency, {100}
%     direS  -  window type, 'both' | {'left'} | 'right'
%     lamHs  -  weight for combing histogram distance, {[.2 .4 .4]}
%     lamPs  -  weight for combing prior, {[.2 .3 .4 .1]}
%     wR     -  window for normalizing saliency, {1}
%     direR  -  window type, {'both'} | 'left' | 'right'
%   varargin
%     save option
%
% Output
%   wsSal    -  salience combination result
%     vdo    -  video path
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 05-27-2013
%   modify   -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% function option
bins = ps(parSal, 'bins', [8 16 16 4 8 9]);
wS = ps(parSal, 'wS', 50);
direS = ps(parSal, 'direS', 'left');
lamHs = ps(parSal, 'lamHs', [.2 .4 .4]);
lamPs = ps(parSal, 'lamPs', [.2 .3 .4 .1]);
wR = ps(parSal, 'wR', 1);
direR = ps(parSal, 'direR', 'both');

% save option
subx = cellStr('sal', bins, wS, lamHs, lamPs, wR, direR);
prex = cellStr(wsSeg.prex, wsSmp.prex, subx);
fold = sprintf('misv/%s/sal', src.tag);
[svL, vdopath] = psSv(varargin, ...
                      'prex', prex, ...
                      'subx', 'salL', ...
                      'fold', fold, ...
                      'type', 'fold');
matpath = sprintf('%s.mat', vdopath);

% load
if svL == 2 && exist(matpath, 'file')
    prInOut('misvSalL', 'old, %s', prex);
    wsSal = matFld(matpath, 'wsSal');
    wsSal.vdo = vdopath;
    return;
end
prIn('misvSalL', 'new, %s', prex);
hTi = tic;

% sampling
[nF, pFs, fps] = stFld(wsSmp, 'nF', 'pFs', 'fps');

% flow
hrFlow = misvRIn(src, 'flow', wsFlow.parFlow);

% video
hrVdo = misvRIn(src);

% feature
sigS = 3;
[SegHstF, SegHstM, SegHstO, SegPriS, SegPriM, SegPriB, SegPriA] = vdoSalVox(hrVdo, hrFlow, wsSmp, wsFlow, wsAcc, wsBk, wsSeg, bins, wS, direS, sigS);

% range
[RHstF0, RHstM0, RHstO0, RPriS0, RPriM0, RPriB0, RPriA0] ...
        = ranXCol(SegHstF, SegHstM, SegHstO, SegPriS, SegPriM, SegPriB, SegPriA);

% normalize range
[RHstF, RHstM, RHstO, RPriS, RPriM, RPriB, RPriA] = ...
    ranConv(wR, direR, RHstF0, RHstM0, RHstO0, RPriS0, RPriM0, RPriB0, RPriA0);

% segmentation
hrSeg = vdoRIn(wsSeg.vdo, 'comp', 'mat');
siz = stFld(hrSeg, 'siz');

% save info.mat
reMkdir(vdopath);
idx = 1 : nF;
pathform = 'frame_%04d.mat';
infopath = sprintf('%s/info.mat', vdopath);
save(infopath, 'nF', 'siz', 'fps', 'pathform', 'idx');

% combine each frame
[R, RHst, RPri] = zeross(2, nF);
prCIn('frame', nF, .1);
for iF = 1 : nF
    prC(iF);

    %% normalize
    segHstFs = ranNor(SegHstF(:, iF), RHstF(:, iF));
    segHstMs = ranNor(SegHstM(:, iF), RHstM(:, iF));
    segHstOs = ranNor(SegHstO(:, iF), RHstO(:, iF));
    segPriSs = ranNor(SegPriS(:, iF), RPriS(:, iF));
    segPriMs = ranNor(SegPriM(:, iF), RPriM(:, iF));
    segPriBs = ranNor(SegPriB(:, iF), RPriB(:, iF));
    segPriAs = ranNor(SegPriA(:, iF), RPriA(:, iF));

    %% combine
    segHsts = lamHs(1) * segHstFs + lamHs(2) * segHstMs + lamHs(3) * segHstOs;
    segPris = lamPs(1) * segPriSs + lamPs(2) * segPriMs + lamPs(3) * segPriBs + lamPs(4) * segPriAs;
    segs = segHsts .* segPris;

    %% range
    [R(:, iF), RHst(:, iF), RPri(:, iF)] = ranX(segs, segHsts, segPris);

    %% write to file
    imgpath = sprintf(['%s/' pathform], vdopath, iF);
    save(imgpath, 'segs', 'segHsts', 'segPris', ...
         'segHstFs', 'segHstMs', 'segHstOs', 'segPriSs', 'segPriMs', 'segPriBs', 'segPriAs');
end
prCOut(nF);

% store
wsSal.prex = prex;
wsSal.subx = subx;
wsSal.vdo = vdopath;
wsSal.parSal = parSal;
wsSal.R = R;
wsSal.RHst = RHst;
wsSal.RPri = RPri;

wsSal.RHstF = RHstF;
wsSal.RHstM = RHstM;
wsSal.RHstO = RHstO;
wsSal.RPriS = RPriS;
wsSal.RPriM = RPriM;
wsSal.RPriB = RPriB;
wsSal.RPriA = RPriA;

wsSal.RHstF0 = RHstF0;
wsSal.RHstM0 = RHstM0;
wsSal.RHstO0 = RHstO0;
wsSal.RPriS0 = RPriS0;
wsSal.RPriM0 = RPriM0;
wsSal.RPriB0 = RPriB0;
wsSal.RPriA0 = RPriA0;

wsSal.ti = toc(hTi);

% save
if svL
    save(matpath, 'wsSal');
end

prOut;
