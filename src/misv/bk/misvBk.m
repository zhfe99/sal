function wsBk = misvBk(src, parBk, varargin)
% Compute background of video.
%
% Input
%   src     -  source
%   parBk   -  background parameter
%     wMa   -  image maximum size, {0}
%     wF    -  window size, {1}
%     dire  -  direction, {'both'} | 'left' | 'right'
%     th    -  threshold for variance, {10}
%   varargin
%     save option
%
% Output
%   wsBk    -  background result
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-03-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% function option
wMa = ps(parBk, 'wMa', 0);
wF = ps(parBk, 'wF', 1);
dire = ps(parBk, 'dire', 'both');
th = ps(parBk, 'th', 0);

% save option
prex = cellStr('wMa', wMa, 'wF', wF, 'dire', dire, 'th', th);
fold = sprintf('misv/%s/bk', src.tag);
[svL, vdopath] = psSv(varargin, ...
                      'fold', fold, ...
                      'prex', prex, ...
                      'subx', 'bk', ...
                      'type', 'fold');
matpath = sprintf('%s.mat', vdopath);

% load
if svL == 2 && exist(matpath, 'file')
    prInOut('misvBk', 'old, %s', prex);
    wsBk = matFld(matpath, 'wsBk');
    wsBk.vdo = vdopath;
    return;
end
prIn('misvBk', 'new, nm %s, wMa %d, wF %d, dire %s, th %d', src.tag, wMa, wF, dire, th);
hTi = tic;

% video in
hrVdo = misvRIn(src);
[nF, siz0, fps] = stFld(hrVdo, 'nF', 'siz', 'fps');

% new size
siz = imgSizFit(siz0, [0 0] + wMa);

% save info.mat
reMkdir(vdopath);
pathform = 'frame%04d.mat';
idx = 1 : nF;
infopath = sprintf('%s/info.mat', vdopath);
save(infopath, 'nF', 'siz', 'fps', 'pathform', 'idx');

% cache
nF0 = nF;
cFs = 1 : nF;
[Ran0, RanC, idxC] = vdoCacheIdx(cFs, nF0, wF, dire);
Fs = zeros(siz(1), siz(2), wF);

% loop the video
iF = 1;
prCIn('frame', nF0, .1);
for pF = 1 : nF0
    prC(pF);

    %% useless frame, skip
    if idxC(pF) == 0
        continue;
    end

    %% read frame
    F0 = vdoR(hrVdo, pF);
    F0 = rgb2gray(F0);
    F = imresize(F0, siz);

    %% update cache
    Fs(:, :, idxC(pF)) = double(F);

    %% not the end of this window, skip
    if pF < Ran0(2, iF)
        continue;
    end

    %% main heavy computation for each key-frame
    while iF <= nF && pF == Ran0(2, iF)
        head = RanC(1, iF);
        tail = RanC(2, iF);
        cen = RanC(3, iF);

        %% median filter
        indC = circleIdx(head, tail, wF);
        B = median(Fs(:, :, indC), 3);

        %% probability
        P = 1 - exp(-(Fs(:, :, cen) - B) .^ 2 / th ^ 2 / 2);

        %% write to file
        P = single(P);
        B = uint8(B);
        imgpath = sprintf(['%s/' pathform], vdopath, iF);
        save(imgpath, 'P', 'B');

        iF = iF + 1;
    end
end
prCOut(nF0);

% store
wsBk.prex = prex;
wsBk.vdo = vdopath;
wsBk.ti = toc(hTi);

% save
if svL
    save(matpath, 'wsBk');
end

prOut;
