function Ks = conKnlTra(PC, PCJ, siz, sig)
% Compute kernel between two feature trajectories on 2-D images.
%
% Input
%   PC      -  trajectory, d (=2) x k x nF
%   PCJ     -  template trajectory, d x kJ x nF
%   siz     -  image size, [h w]
%   sig     -  sigma
%
% Output
%   Ks      -  kernel matrix, kJ x k x nF
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 10-06-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-20-2014

% dimension
[d, k, nF] = size(PC);
kJ = size(PCJ, 2);

% maximum length
h = siz(1);
w = siz(2);
len = max(h, w) ^ 2;

% per frame
Ks = zeros(kJ, k, nF);
for iF = 1 : nF
    PCJi = PCJ(:, :, iF);
    PCi = PC(:, :, iF);

    %% distance
    D = conDst(PCJi, PCi);
    
    %% kernel
    Ks(:, :, iF) = exp(-D ./ (len * sig));
end
