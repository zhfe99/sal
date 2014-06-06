function src = misvSrc(nm, comp)
% Obtain a video source.
%
% Input
%   nm      -  video name
%   comp    -  video format, (optional)
%
% Output
%   src
%     dbe   -  'misv'
%     nm    -  full name
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 09-20-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-13-2014

% video format
if ~exist('comp', 'var')
    comp = 'avi';
end

% store
src.dbe = 'misv';
src.nm = nm;
src.tag = nm;
src.comp = comp;