function wsAcc = misvFlowAcc(src, wsFlow, parAcc, varargin)
% Compute the acceration of optical flow at each pixel.
%
% Input
%   src     -  source
%   wsFlow  -  flow
%   parAcc  -  parameter
%     wA    -  window for cumulating the flow, {1}
%     wF    -  window for smoothing the magitude, {1}
%     dire  -  direction for smoothing, 'left' | 'right' | {'both'}
%   varargin
%     save option
%
% Output
%   wsAcc   -  confidence result
%     prex  -  prex
%     vdo   -  path
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 05-26-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% function option
wA = ps(parAcc, 'wA', 1);
wF = ps(parAcc, 'wF', 1);
dire = ps(parAcc, 'dire', 'both');

% save option
subx = cellStr('wA', wA, 'wF', wF, 'dire', dire);
prex = cellStr(wsFlow.prex, subx);
fold = sprintf('misv/%s/flowAcc', src.tag);
[svL, vdopath] = psSv(varargin, ...
                      'fold', fold, ...
                      'prex', prex, ...
                      'subx', 'acc', ...
                      'type', 'fold');
matpath = sprintf('%s.mat', vdopath);

% load
if svL == 2 && exist(matpath, 'file')
    prInOut('misvFlowAcc', 'old, %s', prex);
    wsAcc = matFld(matpath, 'wsAcc');
    wsAcc.vdo = vdopath;
    if isfield(wsAcc, 'hTi')
        wsAcc.ti = wsAcc.hTi;
    end
    return;
end
prIn('misvFlowAcc', 'new, %s', prex);
hTi = tic;

% flow
hrFlow = misvRIn(src, 'flow', wsFlow.parFlow);
[nF, siz, fps, idx] = stFld(hrFlow, 'nF', 'siz', 'fps', 'idx');
h = siz(1);
w = siz(2);

% save info.mat
reMkdir(vdopath);
pathform = 'frame_%04d.mat';
infopath = sprintf('%s/info.mat', vdopath);
save(infopath, 'nF', 'siz', 'fps', 'pathform', 'idx');

% access the future position using flow
mags = zeros(1, nF);
prCIn('frame', nF, .1);
for pF = 1 : nF
    prC(pF);

    %% index
    pFLs = vdoFiltIdx(pF, wA, 'left', 1, nF); pFLs(1) = [];
    pFRs = vdoFiltIdx(pF, wA, 'right', 1, nF); pFRs(1) = [];

    %% left
    if isempty(pFLs)
        mat = vdoR(hrFlow, pF);
        [VXL, VYL] = stFld(mat, 'VX', 'VY');
    else
        [VXs, VYs] = vdoRMs(hrFlow, pFLs, 'VX', 'VY');
        Ws = vdoFiltWeiGauss(siz, pFLs, 3);
        VXL = vdoFiltCbFlow(VXs, Ws);
        VYL = vdoFiltCbFlow(VYs, Ws);
    end

    %% right
    if isempty(pFRs)
        mat = vdoR(hrFlow, pF);
        [VXR, VYR] = stFld(mat, 'VX', 'VY');
    else
        [VXs, VYs] = vdoRMs(hrFlow, pFRs, 'VX', 'VY');
        Ws = vdoFiltWeiGauss(siz, pFRs, 3);
        VXR = vdoFiltCbFlow(VXs, Ws);
        VYR = vdoFiltCbFlow(VYs, Ws);
    end

    %% compute the difference
    DX = VXL - VXR;
    DY = VYL - VYR;
    M = real(sqrt(DX .^ 2 + DY .^ 2));
    mags(pF) = max(M(:));
    DX = single(DX);
    DY = single(DY);

    %% write to file
    imgpath = sprintf(['%s/' pathform], vdopath, pF - 1);
    save(imgpath, 'DX', 'DY');
end
prCOut(nF);

% smooth the magntitude
magMas = maxConv(mags, wF, dire);

% store
wsAcc.prex = prex;
wsAcc.subx = subx;
wsAcc.vdo = vdopath;
wsAcc.mags = mags;
wsAcc.magMas = magMas;
wsAcc.ti = toc(hTi);

% save
if svL
    save(matpath, 'wsAcc');
end

prOut;
