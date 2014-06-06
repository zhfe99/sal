function hr = misvRIn(src, type, par)
% Obtain the image path for the video source.
%
% Input
%   src     -  wei src
%   type    -  type, 'vdo' | 'flow' | 'vox'
%                'vdo': video frame
%                'flow': optical flow
%                'vox': voxel
%   par     -  parameter
%
% Output
%   hr      -  handler
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 05-29-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

if ~exist('type', 'var')
    type = 'vdo';
end

% path
wsPath = misvPath(src);

% video
if strcmp(type, 'vdo')
    % avi -> image (if necessary)
    if ~exist(wsPath.img, 'file')
        hr = vdoRIn(wsPath.vdo, 'comp', 'vdo');
        vdoAvi2Img(hr, wsPath.img, [], [], [], []);
    end

    hr = vdoRIn(wsPath.img, 'comp', 'img');

% flow
elseif strcmp(type, 'flow')
    wsFlow = misvFlowLiu(src, par, 'svL', 2);
    hr = vdoRIn(wsFlow.vdo, 'comp', 'mat');

% voxel
elseif strcmp(type, 'vox')
    wsVox = misvVox(src, par, 'svL', 2);
    hr = vdoRIn(wsVox.vdo, 'comp', 'img');

else
    error('unknown type: %s', type);
end
