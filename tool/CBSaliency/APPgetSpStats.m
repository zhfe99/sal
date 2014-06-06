function imsegs = APPgetSpStats(imsegs)
% Gets basic information about the superpixels
%
% Input
%   imsegs  -  original segmentation
%
% Output
%   imsegs  -  new segmentation
%
% History
%   create  -  Derek Hoiem, 01-01-2005
%   modify  -  Feng Zhou (zhfe99@gmail.com), 06-21-2013

for ii = 1 : length(imsegs)

    %% dimension
    nseg = imsegs(ii).nseg;
    segimage = double(imsegs(ii).segimage);
    imh = size(segimage, 1);

    %% get adjacency
    adjmat = eye([nseg nseg]);

    %% neighbour in y direction
    dy = segimage ~= segimage([2 : end end], :);
    ind1 = find(dy);
    ind2 = ind1 + 1;
    s1 = segimage(ind1);
    s2 = segimage(ind2);

    adjmat(sub2ind([nseg, nseg], s1, s2)) = 1;
    adjmat(sub2ind([nseg, nseg], s2, s1)) = 1;

    %% neighbour in x direction
    dx = segimage ~= segimage(:, [2 : end end]);
    ind3 = find(dx);
    ind4 = ind3 + imh;
    s3 = segimage(ind3);
    s4 = segimage(ind4);

    adjmat(sub2ind([nseg, nseg], s3, s4)) = 1;
    adjmat(sub2ind([nseg, nseg], s4, s3)) = 1;

    %% region property
    stats = regionprops(segimage, 'Area');
    imsegs(ii).npixels = vertcat(stats(:).Area);
    imsegs(ii).adjmat = logical(adjmat);
end
