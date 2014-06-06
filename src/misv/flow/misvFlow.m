function wsFlow = misvFlow(src, parFlow, varargin)
% Compute optical flow for the video.
%
% Input
%   src      -  source
%   parFlow  -  flow parameter
%     alg    -  algorithm, {'ms'} | 'liu'
%     flip   -  flip flag, {0} | 1
%     wMa    -  image maximum size, {0}
%     wF     -  window for smoothing the magitude, {1}
%     dire   -  direction for smoothing, 'left' | 'right' | {'both'}
%   varargin
%     save option
%
% Output
%   wsFlow   -  flow result
%     prex   -  prex
%     mags   -  mags, magtitude
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 05-26-2013
%   modify   -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% function option
alg = ps(parFlow, 'alg', 'liu');
wMa = ps(parFlow, 'wMa', 400);
flip = ps(parFlow, 'flip', 0);
wF = ps(parFlow, 'wF', 200);
dire = ps(parFlow, 'dire', 'both');
alpha = ps(parFlow, 'alpha', 0.012);
ratio = ps(parFlow, 'ratio', 0.5);
wMi = ps(parFlow, 'wMi', 20);
nOutFP = ps(parFlow, 'nOutFP', 3);
nInFP = ps(parFlow, 'nInFP', 1);
nSOR = ps(parFlow, 'nSOR', 20);
para = [alpha, ratio, wMi, nOutFP, nInFP, nSOR];

% save option
prex = cellStr('alg', alg, 'wMa', wMa, 'flip', flip, 'wF', wF, 'dire', dire, 'para', para);
fold = sprintf('misv/%s/flow', src.tag);
[svL, path] = psSv(varargin, ...
                   'fold', fold, ...
                   'prex', prex, ...
                   'subx', 'flow');

% load
if svL == 2 && exist(path, 'file')
    prInOut('misvFlow', 'old, %s', prex);
    wsFlow = matFld(path, 'wsFlow');
    if isfield(wsFlow, 'hTi')
        wsFlow.ti = wsFlow.hTi;
    end
    return;
end
prIn('misvFlow', 'new, %s', prex);

% flow
wsFlow0 = misvFlowLiu(src, parFlow, 'svL', 2);
hrFlow = misvRIn(src, 'flow', parFlow);

% dimension
[nF, siz0] = stFld(hrFlow, 'nF', 'siz');

% new size
siz = imgSizFit(siz0, [0 0] + wMa);

% compute the magnitute of the optical flow
hTi = tic;
mags = zeros(1, nF);
prCIn('frame', nF, .1);
for iF = 1 : nF
    prC(iF);

    %% read flow
    mat = vdoR(hrFlow, iF);
    [VX, VY] = stFld(mat, 'VX', 'VY');

    %% re-size
    if strcmp(alg, 'ms') && wMa > 0
        VX = imresize(VX, siz);
        VY = imresize(VY, siz);
    end

    %% maximum magtitude value
    M = real(sqrt(VX .^ 2 + VY .^ 2));
    mags(iF) = max(M(:));
end
prCOut(nF);

% smooth the magntitude
magMas = maxConv(mags, wF, dire);

% store
wsFlow.prex = prex;
wsFlow.parFlow = parFlow;
wsFlow.alg = alg;
wsFlow.wMa = wMa;
wsFlow.mags = mags;
wsFlow.magMas = magMas;
wsFlow.ti = wsFlow0.ti + toc(hTi);

% save
if svL
    save(path, 'wsFlow');
end

prOut;
