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
mex maskRegStat.cpp;
mex maskSegRel.cpp;
mex mexMergeAdjacentRegions.cpp
mex relabel_L_fast.cpp
cd ./segment
mex mexSegment.cpp
cd(path0);

% Compiling of Ce Liu's optical flow toolbox
% I have test it on Mac and Ubuntu.
% But it might still generate some error on other platforms.
% Please feel free to skip it and use the compiled mex files from Ce Liu's website (http://people.csail.mit.edu/celiu/OpticalFlow/)
if ispc
    cd 'tool/2009_Thesis_OpticalFlow/mex_win';
else
    cd 'tool/2009_Thesis_OpticalFlow/mex';
end
mex Coarse2FineTwoFrames.cpp OpticalFlow.cpp GaussianPyramid.cpp
cd(path0);
