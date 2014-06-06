% Make file.
path0 = cd;

cd 'lib/position';
mex sortTop.cpp;
cd(path0);

cd 'lib/text';
mex atoi.cpp;
mex atof.cpp;
mex tokenise.cpp;
cd(path0);

cd 'lib/imgMask';
mex maskOver.cpp;
cd(path0);

cd 'lib/reg';
mex computeRegionHist_fast.cpp;
mex computeRegionHof_fast.cpp;
mex computeRegionMag_fast.cpp;
mex computeRegionSpa_fast.cpp;
mex maskRegCen.cpp;
mex maskRegConn.cpp;
% mex maskRegOver.cpp;
mex maskRegStat.cpp;
mex maskSegRel.cpp;
cd(path0);

cd 'tool/CBSaliency';
compile;
cd(path0);

cd 'tool/2009_Thesis_OpticalFlow/mex';
compile;
cd(path0);
