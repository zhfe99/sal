function wsSal = misvSalImg(src, parSal, varargin)
% Compute image-based salience.
%
% Input
%   src      -  source
%   parSal   -  parameter of salience
%     alg    -  saliency algorithm, {'sr'} | 'gbvs' | 'ca' | 'hft' | 'cbsal' | 'cbm'
%                 'sr':   spectral residual
%                 'gbvs': graph-based
%                 'ca':   context-aware
%                 'hft':  hypercomplex Fourier transform
%                 'cbsal': context and shape prior
%   varargin
%     save option
%
% Output
%   wsSal    -  salience result
%     vdo    -  path to the video
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 05-27-2013
%   modify   -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% function option
alg = ps(parSal, 'alg', 'sr');

% save option
prex = cellStr(src.tag, 'alg', alg);
fold = sprintf('misv/%s/salImg', src.tag);
[svL, vdopath] = psSv(varargin, ...
                      'fold', fold, ...
                      'prex', prex, ...
                      'subx', 'sal', ...
                      'type', 'fold');
matpath = sprintf('%s.mat', vdopath);

% load
if svL == 2 && exist(matpath, 'file')
    prInOut('misvSalImg', 'old, %s', prex);
    wsSal = matFld(matpath, 'wsSal');
    wsSal.vdo = vdopath;
    return;
end
prIn('misvSalImg', 'new, %s', prex);
hTi = tic;

% video in
hrVdo = misvRIn(src);
[nF, fps, siz] = stFld(hrVdo, 'nF', 'fps', 'siz');
idx = 1 : nF;

% save info.mat
reMkdir(vdopath);
pathform = 'frame_%04d.mat';
infopath = sprintf('%s/info.mat', vdopath);
save(infopath, 'nF', 'siz', 'fps', 'pathform', 'idx');

% seo
if strcmp(alg, 'seo')
    %% read frames
    Fs = vdoFAll(hrVdo);

    %% run the algorithm
    Ss = vdoSalSeo(Fs);
    
% seo
elseif strcmp(alg, 'cui')
    %% read frames
    Fs = vdoFAll(hrVdo);

    %% run the algorithm
    Ss = vdoSalCui(Fs);    

% rahtu
elseif strcmp(alg, 'rahtu')
    Fs = vdoFAll(hrVdo);

    %% flow
    wsFlow0 = misvFlowLiu(src, [], 'svL', 2);
    hrFlow = misvRIn(src, 'flow', []);
    Vs = cell(1, nF);
    for iF = 1 : nF
        mat = vdoR(hrFlow, iF);
        [VX, VY] = stFld(mat, 'VX', 'VY');
        Vs{iF} = real(sqrt(VX .^ 2 + VY .^ 2));
    end

    Ss = vdoSalRahtu(Fs, Vs);

% qt
elseif strcmp(alg, 'qt')
    Fs = vdoFAll(hrVdo);

    %% flow
    wsFlow0 = misvFlowLiu(src, [], 'svL', 2);
    hrFlow = misvRIn(src, 'flow', []);
    Vs = cell(1, nF);
    for iF = 1 : nF
        mat = vdoR(hrFlow, iF);
        [VX, VY] = stFld(mat, 'VX', 'VY');
        Vs{iF} = real(sqrt(VX .^ 2 + VY .^ 2));
    end

    Ss = vdoSalQt(Fs, Vs);
end

% run on each frame
R = zeros(2, nF);
prCIn('frame', nF, .1);
for iF = 1 : nF
    prC(iF);

    %% read frame
    F = vdoR(hrVdo, iF);

    %% run saliency
    if strcmp(alg, 'sr')
        S = imgSalSr(F);

    elseif strcmp(alg, 'gbvs')
        S = imgSalGbvs(F);

    elseif strcmp(alg, 'itti')
        S = imgSalItti(F);

    elseif strcmp(alg, 'ca')
        S = imgSalCa(F);

    elseif strcmp(alg, 'hft')
        S = imgSalHft(F);

    elseif strcmp(alg, 'itti')
        S = imgSalItti(F);        

    elseif strcmp(alg, 'cbsal')
        S = imgSalCbSalOld(F, []);

    elseif strcmp(alg, 'seo') || strcmp(alg, 'qt') || strcmp(alg, 'rahtu') || strcmp(alg, 'cui')
        S = Ss(:, :, iF);

    else
        error('unknown algorithm %s', alg);
    end

    %% range
    R(:, iF) = ranX(S);

    %% write to file
    imgpath = sprintf(['%s/' pathform], vdopath, iF);
    save(imgpath, 'S');
end
prCOut(nF);

% store
wsSal.prex = prex;
wsSal.vdo = vdopath;
wsSal.parSal = parSal;
wsSal.R = R;
wsSal.ti = toc(hTi);

% save
if svL
    save(matpath, 'wsSal');
end

prOut;
