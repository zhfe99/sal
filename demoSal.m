% An demo file for computing saliency.
%
% History
%   create     -  Feng Zhou (zhfe99@gmail.com), 07-03-2013
%   modify     -  Feng Zhou (zhfe99@gmail.com), 06-23-2014

clear variables;
prSet(4);

%% src
% All video files are located at "./data/mov".
nm = 'eli_walk.avi'; 
src = movSrc(nm);
    
%% run
[wsSal, wsSmp] = movAllSal(src);

%% animate
anMovSal(src, wsSmp, wsSal);
