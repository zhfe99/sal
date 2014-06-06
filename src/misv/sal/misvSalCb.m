function wsSal = misvSalCb(src, wsSmp, wsFlow, wsAcc, wsBk, parSal, varargin)
% Combine video-based salience of high-speed video.
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
%     dire   -  window type, {'both'} | 'left' | 'right'
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
lamHs = ps(parSal, 'lamHs', [.2 .4 .4]);
lamPs = ps(parSal, 'lamPs', [.2 .3 .4 .1]);
Par = ps(parSal, 'Par', ...
         [0.3, 350, 1200; ...
          0.4, 350, 1200; ...
          0.5, 350, 1200; ...
          0.6, 350, 1200; ...
          0.7, 350, 1200; ...
          0.8, 350, 1200; ...
          0.9, 350, 1200; ...
          1.0, 350, 1200]);
th = .2;

% save option
subx = cellStr('bins', bins, 'lamHs', lamHs, 'lamPs');
prex = cellStr(src.tag, wsSmp.subx, subx);
[svL, vdopath] = psSv(varargin, ...
                      'prex', prex, ...
                      'subx', 'salCb', ...
                      'fold', 'misv/sal', ...
                      'type', 'fold');
matpath = sprintf('%s.mat', vdopath);

% load
if svL == 2 && exist(matpath, 'file')
    prInOut('misvSalCb', 'old, %s', prex);
    wsSal = matFld(matpath, 'wsSal');
    wsSal.vdo = vdopath;
    return;
end
prIn('misvSalCb', 'new, %s', prex);

% sampling
[nF, pFs, fps] = stFld(wsSmp, 'nF', 'pFs', 'fps');

% video
hrVdo = misvRIn(src);

% flow
hrFlow = misvRIn(src, 'flow', wsFlow.parFlow);
magMas = stFld(wsFlow, 'magMas');
siz = stFld(hrFlow, 'siz');

% acceleration
magMaAs = stFld(wsAcc, 'magMas');
hrAcc = vdoRIn(wsAcc.vdo, 'comp', 'mat');

% background
hrBk = vdoRIn(wsBk.vdo, 'comp', 'mat');

% save info.mat
reMkdir(vdopath);
idx = 1 : nF;
pathform = 'frame_%04d.mat';
infopath = sprintf('%s/info.mat', vdopath);
save(infopath, 'nF', 'siz', 'fps', 'pathform', 'idx');

% loop the video
prCIn('frame', nF, .1);
R = zeros(2, nF);
for iF = 1 : nF
    prC(iF);
    pF = pFs(iF);

    %% read frame
    F0 = vdoR(hrVdo, pF);
    F = imresize(F0, siz);

    %% read flow
    mat = vdoR(hrFlow, pF);
    [VX, VY] = stFld(mat, 'VX', 'VY');
    VX = double(VX);
    VY = double(VY);

    %% read acc
    mat = vdoR(hrAcc, pF);
    [DX, DY] = stFld(mat, 'DX', 'DY');
    DX = double(DX);
    DY = double(DY);

    %% mag
    M = real(sqrt(VX .^ 2 + VY .^ 2));
    M = M ./ (magMas(pF) + eps);
    MA = real(sqrt(DX .^ 2 + DY .^ 2));
    MA = MA ./ (magMaAs(pF) + eps);

    %% background
    mat = vdoR(hrBk, pF);
    P = double(mat.P);

    %% quantize
    FQ = computeQuantMatrixImg(F, bins(1 : 4));
    MQ = computeQuantMatrixFlow(M, bins(5));

    %% segmentation
    [Ls, As, mSegs] = imgSalCbSalSeg(F, Par, bins(1 : 4), th);

    %% core
    S = vdoSalCbCore(Ls, As, mSegs, bins, lamHs, lamPs, FQ, MQ, M, MA, VX, VY, P);

    %% range
    R(:, iF) = ranX(S);

    %% write to file
    imgpath = sprintf(['%s/' pathform], vdopath, iF);
    save(imgpath, 'S');
end
prCOut(nF);

% store
wsSal.prex = prex;
wsSal.subx = subx;
wsSal.vdo = vdopath;
wsSal.parSal = parSal;
wsSal.R = R;

% save
if svL
    save(matpath, 'wsSal');
end

prOut;
