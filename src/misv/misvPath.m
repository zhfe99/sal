function wsPath = misvPath(src)
% Obtain the avi/mat file path for Video source.
%
% Input
%   src     -  video src
%
% Output
%   wsPath
%     vdo   -  path of vdo file
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 09-20-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-13-2014

% specified in addPath.m
global footpath;

[nm, comp] = stFld(src, 'nm', 'comp');

% data folder
foldpath = sprintf('%s/data/misv', footpath);

% avi
wsPath.avi = sprintf('%s/%s.avi', foldpath, nm);
wsPath.img = sprintf('%s/%s', foldpath, nm);

% img
if strcmp(comp, 'img')
    wsPath.vdo = wsPath.img;
else
    wsPath.vdo = wsPath.avi;
end
    
% feature
wsPath.feat = sprintf('%s/%s.txt', foldpath, nm);
