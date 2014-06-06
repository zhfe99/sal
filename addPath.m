function addPath
% Add folders of predefined functions into matlab searching paths.
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-20-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 03-19-2014

global footpath;
footpath = cd;

% for windows
idx = find(footpath == '\');
for i = 1 : length(idx)
    footpath(idx(i)) = '/';
end

%addpath(genpath([footpath '/tool2/mosek64/6/toolbox/r2009b']));
addpath(genpath([footpath '/tool']));
addpath(genpath([footpath '/core']));
addpath(genpath([footpath '/src']));
addpath(genpath([footpath '/lib']));
addpath(genpath([footpath '/mex']));

% random seed generation
RandStream.setGlobalStream(RandStream('mt19937ar', 'seed', sum(100 * clock)));

% cd test/stm/mhad;
% cd test/data/misv;
