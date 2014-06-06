function wsSmp = misvSmp(src, wsVdo, parSmp, varargin)
% Sampling the video.
%
% Input
%   src     -  src
%   video   -  video
%   parSmp  -  sampling parameter
%     alg   -  algorithm, 'uni'
%     fps   -  frame rate, {30}
%     ran   -  range, {[1 0]}
%   varargin
%     save option
%
% Output
%   wsSmp   -  sampling result
%     prex  -  name
%     nF    -  #frame
%     fps   -  frame rate
%     pFs   -  frame index, 1 x nF
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 05-23-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-18-2014

% function option
alg = ps(parSmp, 'alg', 'uni');
fps = ps(parSmp, 'fps', wsVdo.hr.fps);
ran = ps(parSmp, 'ran', [1 0]);

% save option
prex = cellStr(src.nm, 'alg', alg, 'fps', fps, 'ran', ran);
[svL, path] = psSv(varargin, ...
                   'prex', prex, ...
                   'fold', 'misv/smp', ...
                   'subx', 'smp');

% load
if svL == 2 && exist(path, 'file')
    prInOut('misvSmp', 'old, %s', prex);
    wsSmp = matFld(path, 'wsSmp');
    return;
end
prIn('misvSmp', 'new, %s', prex);
hTi = tic;

% video in
hr = stFld(wsVdo, 'hr');
[nF0, fps0] = stFld(hr, 'nF', 'fps');

% crop
if ran(2) == 0
    ran(2) = nF0;
end
pF0s = ran(1) : ran(2);
nF0 = length(pF0s);

% uniform sampling
[pFs, nF] = vdoSmpUni(1, nF0, fps0, fps);
pFs = pF0s(pFs);

% store
wsSmp.prex = prex;
wsSmp.fps0 = fps0;
wsSmp.fps = fps;
wsSmp.nF0 = nF0;
wsSmp.nF = nF;
wsSmp.pF0s = pF0s;
wsSmp.pFs = pFs;

% save
if svL > 0
    save(path, 'wsSmp');
end

prOut;
