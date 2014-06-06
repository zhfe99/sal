% An demo file for computing saliency.
%
% History
%   create     -  Feng Zhou (zhfe99@gmail.com), 07-03-2013
%   modify     -  Feng Zhou (zhfe99@gmail.com), 06-06-2014

clear variables;
prSet(4);

%% src
nm = 'eli_walk';      % The real video file is located at "./data/misv/eli_walk.avi".
                      % Change "nm" to other name as you want, eg. nm = 'soccer_juggle'.
src = misvSrc(nm);
    
%% run
[wsSal, wsSmp] = misvAllSal(src);

%% animate
anMisvSal(src, wsSmp, wsSal);
