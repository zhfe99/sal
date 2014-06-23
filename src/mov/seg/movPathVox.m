function wsPath = movPathVox(src, parVox)
% Obtain the image path for the High-Speed source.
%
% Input
%   src     -  src
%   parVox  -  parameter
%
% Output
%   wsPath
%     cmd   -  path of command file
%     ppm   -  path of segmentation file
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 05-29-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 06-23-2014

% specified in addPath.m
global footpath;

% data folder
foldpath = sprintf('%s/data/mov/vox/%s', footpath, src.nm);

% parameter
[wMa, cl] = stFld(parVox, 'wMa', 'cl');

% input path
if strcmp(cl, 'hsv') || strcmp(cl, 'lab')
    wsPath.ppm = sprintf('%s/ppm_%d', foldpath, wMa);
else
    wsPath.ppm = sprintf('%s/ppm_%d_%s', foldpath, wMa, cl);
end

% cmd path
if ispc
    s = computer;
    if strcmp(s(end - 1 : end), '64')
        subx = 'win64.exe';
    else
        subx = 'win32.exe';
    end
elseif ismac
    subx = 'osx';
else
    subx = 'linux';
end
wsPath.cmd = sprintf('%s/tool/2012_ECCV_LIBSVX/gbh_stream_%s', footpath, subx);
