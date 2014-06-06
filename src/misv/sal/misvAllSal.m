function [wsSal, wsSmp, wsFlow, wsAcc, wsBk, wsSals, wsVoxs, wsSegs] = misvAllSal(src)
% Obtain the saliency.
%
% Input
%   src     -  hs src
%
% Output
%   wsSal   -  saliency
%   wsSco   -  saliency score
%   wsSals  -  saliency for each level, 1 x mL (cell)
%   wsSegs  -  segementation for each level, 1 x mL (cell)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 07-02-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 03-19-2014

prIn('misvAllSal', 'tag %s', src.tag);

% parameter
[parSmp, parFlow, parAcc, parBk, parVoxs, parSeg, parSal] = misvParSal(src);

% video
wsVdo = misvVdo(src, 'svL', 2);

% sampling
wsSmp = misvSmp(src, wsVdo, parSmp, 'svL', 2);

% flow
wsFlow = misvFlow(src, parFlow, 'svL', 2);

% acc
wsAcc = misvFlowAcc(src, wsFlow, parAcc, 'svL', 2);

% bk
wsBk = misvBk(src, parBk, 'svL', 2);

% seg & sal
mL = length(parVoxs);
[wsVoxs, wsSegs, wsSals] = cellss(1, mL);
for iL = 1 : mL
    wsVoxs{iL} = misvVox(src, wsFlow, parVoxs{iL}, 'svL', 2);
    wsSegs{iL} = misvSegL(src, wsVoxs{iL}, parSeg, 'svL', 2);
    wsSals{iL} = misvSalL(src, wsSmp, wsFlow, wsAcc, wsBk, wsSegs{iL}, parSal, 'svL', 2);
end

% combine
wsSal = misvSalCmb(src, wsSmp, wsSegs, wsSals, parSal, 'svL', 2);

prOut;
