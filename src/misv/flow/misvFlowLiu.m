function wsFlow = misvFlowLiu(src, parFlow, varargin)
% Compute optical flow for the video.
%
% Input
%   src      -  source
%   parFlow  -  flow parameter
%     wMa    -  maximum image width, {400}
%     flip   -  flip flag, {0} | 1
%     see function Coarse2FineTwoFrames for more details
%   varargin
%     save option
%
% Output
%   wsFlow   -  flow result
%     vdo    -  video
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 05-26-2013
%   modify   -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% function option
wMa = ps(parFlow, 'wMa', 400);
flip = ps(parFlow, 'flip', 0);

% parameter for Ce Liu's code
alpha = ps(parFlow, 'alpha', 0.012);
ratio = ps(parFlow, 'ratio', 0.5);
wMi = ps(parFlow, 'wMi', 20);
nOutFP = ps(parFlow, 'nOutFP', 3);
nInFP = ps(parFlow, 'nInFP', 1);
nSOR = ps(parFlow, 'nSOR', 20);
para = [alpha, ratio, wMi, nOutFP, nInFP, nSOR];

% save option
prex = cellStr('wMa', wMa, 'flip', flip, 'para', para);
fold = sprintf('misv/%s/flowLiu', src.tag);
[svL, vdopath] = psSv(varargin, ...
                      'fold', fold, ...
                      'prex', prex, ...
                      'subx', 'flow', ...
                      'type', 'fold');
matpath = sprintf('%s.mat', vdopath);

% load
if svL == 2 && exist(matpath, 'file')
    prInOut('misvFlowLiu', 'old, %s', prex);
    wsFlow = matFld(matpath, 'wsFlow');
    wsFlow.vdo = vdopath;
    return;
end
prIn('misvFlowLiu', 'new, %s', prex);
hTi = tic;

% video in
hrVdo = misvRIn(src);
[nF, siz0, fps, idx] = stFld(hrVdo, 'nF', 'siz', 'fps', 'idx');

% new size
siz = imgSizFit(siz0, [0 0] + wMa);

% save info.mat
reMkdir(vdopath);
pathform = 'frame%04d.mat';
infopath = sprintf('%s/info.mat', vdopath);
save(infopath, 'nF', 'siz', 'fps', 'pathform', 'idx');

% run each frame
if flip == 0
    flowFord(hrVdo, siz, nF, pathform, vdopath, para);
else
    flowBack(hrVdo, siz, nF, pathform, vdopath, para);
end

% store
wsFlow.prex = prex;
wsFlow.vdo = vdopath;
wsFlow.ti = toc(hTi);

% save
if svL
    save(matpath, 'wsFlow');
end

prOut;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flowFord(hrVdo, siz, nF, pathform, vdopath, para)
% Compute flow forward.
%
% Input
%   hrVdo     -  handler of video
%   siz       -  image size, 1 x 2
%   nF        -  #frame
%   pathform  -  path form
%   vdopath   -  video folder
%   para      -  parameter

% first frame
Fs = cell(1, 2);
p0 = mod(1, 2) + 1;
F0 = vdoR(hrVdo, 1);
F = imresize(F0, siz);
Fs{p0} = im2double(F);

% compute optical flow for each pair of frame
prCIn('frame', nF, .1);
for iF = 2 : nF
    prC(iF);

    %% read frame
    F0 = vdoR(hrVdo, iF);
    F = imresize(F0, siz);

    %% current frame
    p = mod(iF, 2) + 1;
    Fs{p} = im2double(F);

    %% core
    [VX, VY] = Coarse2FineTwoFrames(Fs{p0}, Fs{p}, para);
    VX = single(VX);
    VY = single(VY);

    %% write to mat file
    matfile = sprintf(['%s/' pathform], vdopath, iF - 2);
    save(matfile, 'VX', 'VY');

    %% store
    p0 = p;
end
prCOut(nF);

% last frame
matfile = sprintf(['%s/' pathform], vdopath, nF - 1);
save(matfile, 'VX', 'VY');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flowBack(hrVdo, siz, nF, pathform, vdopath, para)
% Compute flow backward.
%
% Input
%   hrVdo     -  handler of video
%   siz       -  image size, 1 x 2
%   nF        -  #frame
%   pathform  -  path form
%   vdopath   -  video folder
%   para      -  parameter

% first frame
Fs = cell(1, 2);
p0 = mod(1, 2) + 1;
F0 = vdoR(hrVdo, 1);
F = imresize(F0, siz);
Fs{p0} = im2double(F);

% compute optical flow for each pair of frame
prCIn('frame', nF, .1);
for iF = 2 : nF
    prC(iF);

    %% read frame
    F0 = vdoR(hrVdo, iF);
    F = imresize(F0, siz);

    %% current frame
    p = mod(iF, 2) + 1;
    Fs{p} = im2double(F);

    %% core
    [VX, VY] = Coarse2FineTwoFrames(Fs{p}, Fs{p0}, para);
    VX = single(VX);
    VY = single(VY);

    %% save for the first frame
    if iF == 2
        matfile = sprintf(['%s/' pathform], vdopath, iF - 2);
        save(matfile, 'VX', 'VY');
    end

    %% write to mat file
    matfile = sprintf(['%s/' pathform], vdopath, iF - 1);
    save(matfile, 'VX', 'VY');

    %% store
    p0 = p;
end
prCOut(nF);