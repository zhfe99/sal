function src = movSrc(nm, comp)
% Obtain a video source.
%
% Input
%   nm      -  video name
%   comp    -  video format, (optional)
%
% Output
%   src
%     dbe   -  'mov'
%     nm    -  full name
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 09-20-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 06-23-2014

% video format
if ~exist('comp', 'var')
    comp = 'avi';
end

% video contain the extension
pos = 0;
for i = 1 : length(nm)
    if strcmp(nm(i), '.')
        pos = i;
        break;
    end
end
if pos > 0
    comp = nm(i + 1 : end);
    nm = nm(1 : i - 1);
end

% store
src.dbe = 'mov';
src.nm = nm;
src.tag = nm;
src.comp = comp;