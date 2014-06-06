function wsSld = misvSld(wsSmp, parSld, varargin)
% Obtain sliding window.
%
% Input
%   wsSmp   -  sampling
%   parSld  -  parameter
%     len   -  window length, {16} | 15 | ...
%     gap   -  window gap, {1} | ...
%   varargin
%     save option
%
% Output
%   wsSld
%     prex  -  name
%     nSeg  -  #windows
%     Idx   -  frame index, len x nSeg
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 02-05-2014

% function option
len = ps(parSld, 'len', 16);
gap = ps(parSld, 'gap', 1);

% save option
prex = cellStr(wsSmp.prex, 'len', len);
[svL, path] = psSv(varargin, ...
                   'prex', prex, ...
                   'subx', 'sld', ...
                   'fold', 'misv/sld');

% load
if svL == 2 && exist(path, 'file')
    prInOut('misvSld', 'old, %s', prex);
    wsSld = matFld(path, 'wsSld');
    return;
end
prIn('misvSld', 'new, %s', prex);

% sliding window
[nSeg, Idx] = vdoSld(wsSmp.nF, len, gap);

% store
wsSld.prex = prex;
wsSld.nSeg = nSeg;
wsSld.Idx = Idx;

% save
if svL > 0
    save(path, 'wsSld');
end

prOut;
