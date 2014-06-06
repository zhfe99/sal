function wsSal = misvSalCmb(src, wsSmp, wsSegs, wsSals, parSal, varargin)
% Combine video-based salience of high-speed video.
%
% Input
%   src     -  source
%   wsSmp   -  sampling
%   wsSegs  -  video segmentation, 1 x mL (cell)
%   wsSals  -  video saliency, 1 x mL (cell)
%   parSal  -  parameter of salience
%   varargin
%     save option
%
% Output
%   wsSal   -  salience combination result
%     vdo   -  video path
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 05-27-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% save option
mL = length(wsSals);
prex = wsSals{1}.prex;
fold = sprintf('misv/%s/sal', src.tag);
[svL, vdopath] = psSv(varargin, ...
                      'prex', prex, ...
                      'subx', 'cmb', ...
                      'fold', fold, ...
                      'type', 'fold');
matpath = sprintf('%s.mat', vdopath);

% load
if svL == 2 && exist(matpath, 'file')
    prInOut('misvSalCmb', 'old, %s', prex);
    wsSal = matFld(matpath, 'wsSal');
    wsSal.vdo = vdopath;
    return;
end
prIn('misvSalCmb', 'new, %s', prex);
hTi = tic;

% sampling
pFs = stFld(wsSmp, 'pFs');

% segmentation & saliency in
[hrSegs, hrSals] = cellss(1, mL);
for iL = 1 : mL
    hrSegs{iL} = vdoRIn(wsSegs{iL}.vdo, 'comp', 'mat');
    hrSals{iL} = vdoRIn(wsSals{iL}.vdo, 'comp', 'mat');
end
[nF, siz, fps, idx, pathform] = stFld(hrSals{1}, 'nF', 'siz', 'fps', 'idx', 'pathform');

% save info.mat
reMkdir(vdopath);
infopath = sprintf('%s/info.mat', vdopath);
save(infopath, 'nF', 'siz', 'fps', 'pathform', 'idx');

[R, RHst, RPri, RHstF, RHstM, RHstO, RPriS, RPriM, RPriB, RPriA] = zeross(2, nF);
prCIn('frame', nF, .1);
for iF = 1 : nF
    prC(iF);
    pF = pFs(iF);

    %% each level
    for iL = 1 : mL
        %% segmentation
        mat = vdoR(hrSegs{iL}, pF);
        L = double(mat.L);

        %% saliency (segment)
        mat = vdoR(hrSals{iL}, iF);
        [segs, segHsts, segPris, segHstFs, segHstMs, segHstOs, segPriSs, segPriMs, segPriBs, segPriAs] = ...
            stFld(mat, 'segs', 'segHsts', 'segPris', 'segHstFs', 'segHstMs', 'segHstOs', 'segPriSs', 'segPriMs', 'segPriBs', 'segPriAs');

        %% saliecy (pixel)
        Si = segs(L);
        SHsti = segHsts(L);
        SPrii = segPris(L);
        SHstFi = segHstFs(L);
        SHstMi = segHstMs(L);
        SHstOi = segHstOs(L);
        SPriSi = segPriSs(L);
        SPriMi = segPriMs(L);
        SPriBi = segPriBs(L);
        SPriAi = segPriAs(L);

        %% combine (pixel) (accros level)
        if iL == 1
            S = Si;
            SHst = SHsti;
            SPri = SPrii;
            SHstF = SHstFi;
            SHstM = SHstMi;
            SHstO = SHstOi;
            SPriS = SPriSi;
            SPriM = SPriMi;
            SPriB = SPriBi;
            SPriA = SPriAi;
        else
            S = S + Si;
            SHst = SHst + SHsti;
            SPri = SPri + SPrii;
            SHstF = SHstF + SHstFi;
            SHstM = SHstM + SHstMi;
            SHstO = SHstO + SHstOi;
            SPriS = SPriS + SPriSi;
            SPriM = SPriM + SPriMi;
            SPriB = SPriB + SPriBi;
            SPriA = SPriA + SPriAi;
        end
    end

    %% nomalize (pixel)
    S = S / mL;
    SHst = SHst / mL;
    SPri = SPri / mL;
    SHstF = SHstF / mL;
    SHstM = SHstM / mL;
    SHstO = SHstO / mL;
    SPriS = SPriS / mL;
    SPriM = SPriM / mL;
    SPriB = SPriB / mL;
    SPriA = SPriA / mL;

    %% range (pixel)
    [R(:, iF), RHst(:, iF), RPri(:, iF), RHstF(:, iF), RHstM(:, iF), RHstO(:, iF), RPriS(:, iF), RPriM(:, iF), RPriB(:, iF), RPriA(:, iF)] = ...
        ranX(S, SHst, SPri, SHstF, SHstM, SHstO, SPriS, SPriM, SPriB, SPriA);

    %% write to file
    imgpath = sprintf(['%s/' pathform], vdopath, iF);
    save(imgpath, 'S', 'SHst', 'SPri', 'SHstF', 'SHstM', 'SHstO', 'SPriS', 'SPriM', 'SPriB', 'SPriA');
end
prCOut(nF);

% store
wsSal.prex = prex;
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
wsSal.ti = toc(hTi);

% save
if svL
    save(matpath, 'wsSal');
end

prOut;
