function [wsSal, wsSmp, wsFlow, wsAcc, wsBk, wsSals, wsVoxs, wsSegs] = movAllSal(src)
% Obtain the saliency of a given video src.
%
% Input
%   src     -  video src
%
% Output
%   wsSal   -  saliency
%   wsSmp   -  sampling
%   wsFlow  -  optical flow
%   wsAcc   -  acceleration
%   wsBk    -  background
%   wsSals  -  saliency for each level, 1 x mL (cell)
%   wsVoxs  -  voxel for each level, 1 x mL (cell)
%   wsSegs  -  segementation for each level, 1 x mL (cell)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 07-02-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 06-23-2014

prIn('movAllSal', 'tag %s', src.tag);

% parameter
[parSmp, parFlow, parAcc, parBk, parVoxs, parSeg, parSal] = movParSal(src);

% video
wsVdo = movVdo(src, 'svL', 2);

% sampling
wsSmp = movSmp(src, wsVdo, parSmp, 'svL', 2);

% flow
wsFlow = movFlow(src, parFlow, 'svL', 1);

% acc
wsAcc = movFlowAcc(src, wsFlow, parAcc, 'svL', 1);

% bk
wsBk = movBk(src, parBk, 'svL', 1);

% seg & sal
mL = length(parVoxs);
[wsVoxs, wsSegs, wsSals] = cellss(1, mL);
for iL = 1 : mL
    wsVoxs{iL} = movVox(src, wsFlow, parVoxs{iL}, 'svL', 1);
    wsSegs{iL} = movSegL(src, wsVoxs{iL}, parSeg, 'svL', 1);
    wsSals{iL} = movSalL(src, wsSmp, wsFlow, wsAcc, wsBk, wsSegs{iL}, parSal, 'svL', 1);
end

% combine
wsSal = movSalCmb(src, wsSmp, wsSegs, wsSals, parSal, 'svL', 1);

prOut;
