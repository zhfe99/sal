function wsVox = misvVox(src, wsFlow, parVox, varargin)
% Over-segment the HS sequence into super-voxels.
%
% Input
%   src     -  hs src
%   parVox  -  voxel parameter
%   varargin
%     save option
%
% Output
%   wsVox   -  voxel result
%     Ls    -  label
%     mSeg  -  #segments
%     A     -  adjacency matrix, mSeg x mSeg
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 05-23-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% function option
wMa = ps(parVox, 'wMa', 400);
c = ps(parVox, 'c', 5);
c_reg = ps(parVox, 'c_reg', 200);
mi = ps(parVox, 'mi', 100);
sigma = ps(parVox, 'sigma', 0.5);
range = ps(parVox, 'range', 10);
nL = ps(parVox, 'nL', 20);
cl = ps(parVox, 'cl', 'hsv');

% save option
if strcmp(cl, 'hsv')
    prex = sprintf('para_%d_%d_%d_%d_%.2f_%d_%d', wMa, c, c_reg, mi, sigma, range, nL);
else
    prex = sprintf('para_%d_%d_%d_%d_%.2f_%d_%d_%s', wMa, c, c_reg, mi, sigma, range, nL, cl);
end
fold = sprintf('misv/%s/vox', src.tag);
[svL, vdopath] = psSv(varargin, ...
                      'prex', prex, ...
                      'subx', 'vox', ...
                      'fold', fold, ...
                      'type', 'fold');
matpath = sprintf('%s.mat', vdopath);

% load
if svL == 2 && exist(matpath, 'file')
    prInOut('misvVox', 'old, %s', prex);
    wsVox = matFld(matpath, 'wsVox');
    wsVox.vdo = vdopath;
    return;
end
prIn('misvVox', 'new, %s', prex);

% video in
hrVdo = misvRIn(src);
[nF, siz0, fps] = stFld(hrVdo, 'nF', 'siz', 'fps');

% flow in
if ~isempty(wsFlow)
    hrFlow = misvRIn(src, 'flow', wsFlow.parFlow);
    magMas = stFld(wsFlow, 'magMas');
end

% new size
siz = imgSizFit(siz0, [0 0] + wMa);

% path
wsPath = misvPathVox(src, parVox);
[ppmpath, cmd] = stFld(wsPath, 'ppm', 'cmd');

% convert to ppm file
if 0 || ~exist(ppmpath, 'dir')
    pr('convert to ppm');
    reMkdir(ppmpath);
    for pF = 1 : nF
        F0 = vdoR(hrVdo, pF);
        F = imresize(F0, siz);
        %% add flow
        if ~strcmp(cl, 'hsv') && ~strcmp(cl, 'lab')
            %% flow
            mat = vdoR(hrFlow, pF);
            [VX, VY] = stFld(mat, 'VX', 'VY');
            VX = double(VX);
            VY = double(VY);
            M = real(sqrt(VX .^ 2 + VY .^ 2));
            M = M ./ (magMas(pF) + eps);

            F = imgClM(F, cl, M);
        end
        imgpath = sprintf('%s/%05d.ppm', ppmpath, pF);
        imwrite(F, imgpath, 'ppm');
    end
end

% run
hTi = tic;
cmdL = sprintf('%s %d %d %d %.2f %d %d %s %s', cmd, c, c_reg, mi, sigma, range, nL, ppmpath, vdopath);
system(cmdL);

% save info.mat
infopath = sprintf('%s/info.mat', vdopath);
pathform = '00/%05d.ppm';
idx = 1 : nF;
save(infopath, 'nF', 'siz', 'fps', 'pathform', 'idx');

% check
isDone = 1;
for iF = 1 : nF
    imgpath = sprintf(['%s/' pathform], vdopath, iF);
    if ~exist(imgpath, 'file')
        isDone = 0;
        break;
    end
end
if ~isDone
    error('not finished at frame %d', iF);
end

% store
wsVox.prex = prex;
wsVox.parVox = parVox;
wsVox.vdo = vdopath;
wsVox.ti = toc(hTi);

% save
if svL > 0
    save(matpath, 'wsVox');
end

prOut;
