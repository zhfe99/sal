function [parSmp, parFlow, parAcc, parBk, parVoxs, parSeg, parSal] = misvParSal(src)
% Obtain the default parameter for saliency.
%
% Input
%   src      -  hs src
%
% Output
%   parSmp   -  sampling parameter
%   parFlow  -  flow parameter
%   parAcc   -  flow acceleration parameter
%   parBk    -  background parameter
%   parVox   -  voxel parameter
%   parSeg   -  segmentation parameter
%   parSal   -  saliency parameter
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 06-02-2013
%   modify   -  Feng Zhou (zhfe99@gmail.com), 03-19-2014

% src
tag = src.tag;

% default sampling parameter
parSmp = st('alg', 'uni', 'fps', 0);

% default acceleration parameter
parAcc = st('wF', 1, 'dire', 'both', 'wA', 5);

% default flow parameter
wMa = 400; wF = 2000; % wF = 200;
parFlow = st('alg', 'liu', 'wMa', wMa, 'wF', wF, 'dire', 'both');

% default background parameter
parBk = st('wMa', wMa, 'wF', 200, 'dire', 'both', 'th', 10);

% default voxel parameter
c_reg = 200; % not used
range = 10;
parVox = st('wMa', wMa, 'c_reg', c_reg, 'range', range, 'nL', 0, 'cl', 'hsv');
nL = 2;
sigs = linspace(.5, .5, nL);
cs = round(linspace(10, 100, nL));
mis = round(linspace(100, 100, nL));
for cL = 1 : nL
    parVoxs{cL} = stAdd(parVox, 'c', cs(cL), 'mi', mis(cL), 'sigma', sigs(cL));
end

% default segmentation parameter
bins = [8 16 16 4 16 9];
th = .1;
parSeg = st('bins', bins, 'th', th);

% default saliency parameter
wS = 50;
wR = 2000;
direR = 'both';
direS = 'both';
lamHs = [.2 .6 .2];
lamPs = [.2 .3 .4 .1];
parSal = st('bins', bins, 'lamHs', lamHs, 'lamPs', lamPs, 'wR', wR, 'direR', direR, 'wS', wS, 'direS', direS);
