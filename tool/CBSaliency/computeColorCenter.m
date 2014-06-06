function Cen = computeColorCenter(F, L, cLs, m)
% Compute color center.
%
% Input
%   F       -  image, h x w x nC
%   L       -  label, h x w
%   cLs     -  region index, 1 x nL
%   m       -  #region
%
% Output
%   Cen     -  color center, m x (nC =3)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-03-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 06-22-2013

% each channel
r = F(:, :, 1);
g = F(:, :, 2);
b = F(:, :, 3);           % all in the range of [0, 1]

% color
Cen = zeros(m, 3);        % r, g, b respectively
for iL = 1 : length(cLs)
    cL = cLs(iL);
    ind = find(L == cL);
    Cen(cL, 1) = mean(r(ind));
    Cen(cL, 2) = mean(g(ind));
    Cen(cL, 3) = mean(b(ind));
end
