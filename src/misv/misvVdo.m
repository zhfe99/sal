function wsVdo = misvVdo(src, parVdo, varargin)
% Obtain video sequence.
%
% Input
%   src     -  misv src
%   parVdo  -  parameter
%   varargin
%     save option
%
% Output
%   wsVdo
%     Fs    -  frame matrix, 1 x nF (cell)
%     siz   -  size of image, 1 x 2
%     nF    -  #frames
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-03-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-13-2014

% function parameter

% save option
prex = src.nm;
[svL, path] = psSv(varargin, ...
                   'fold', 'misv/vdo', ...
                   'prex', prex, ...
                   'subx', 'vdo');

% load
if svL == 2 && exist(path, 'file')
    prInOut('misvVdo', 'old, %s', prex);
    wsVdo = matFld(path, 'wsVdo');
    return;
end
prIn('misvVdo', 'new, %s', prex);

% path
wsPath = misvPath(src);

% video
if strcmp(src.comp, 'img')
    hr = vdoRIn(wsPath.vdo, 'comp', 'img');
else
    hr = vdoRIn(wsPath.vdo, 'comp', 'vdo');
end

% store
wsVdo.prex = prex;
wsVdo.hr = hr;
wsVdo.nF = hr.nF;

% save
if svL > 0
    save(path, 'wsVdo');
end

prOut;
