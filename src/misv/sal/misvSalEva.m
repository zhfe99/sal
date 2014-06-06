function wsEva = misvSalEva(src, wsSal, parEva, varargin)
% Evaluate the salience result.
%
% Input
%   src      -  source
%   wsSal    -  saliency
%   parEva   -  parameter
%     nL     -  #level, {255}
%   varargin
%     save option
%
% Output
%   wsEva    -  evaluation
%     Pre    -  precision, nL x nF
%     Rec    -  recall, nL x nF
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 07-27-2013
%   modify   -  Feng Zhou (zhfe99@gmail.com), 03-11-2014

% function option
nL = ps(parEva, 'nL', 255);

% save option
subx = cellStr('nL', nL);
prex = cellStr(wsSal.prex, subx);
fold = sprintf('misv/%s/eva', src.tag);
[svL, matpath] = psSv(varargin, ...
                      'prex', prex, ...
                      'fold', fold);

% load
if svL == 2 && exist(matpath, 'file')
    prInOut('misvSalEva', 'old, %s', prex);
    wsEva = matFld(matpath, 'wsEva');
    return;
end
prIn('misvSalEva', 'new, %s', prex);

% sal in
hrSal = vdoRIn(wsSal.vdo, 'comp', 'mat');
[siz, nF] = stFld(hrSal, 'siz', 'nF');

% evaluate
ths = linspace(0, 1, nL);
mask_threshold = 0.5;
pr_div_by_zero_result = 1;

% each frame
[Pre, Rec, Fc] = zeross(nL, nF);
prCIn('frame', nF, .1);
for iF = 1 : nF
    prC(iF);

    %% read sal
    mat = vdoR(hrSal, iF);
    S = stFld(mat, 'S');
    miS = min(S(:));
    maS = max(S(:));
    S = (S - miS) / (maS - miS);
    S = double(S);

    %% mask
    Pt = src.Pts{iF};
    ST = zeros(siz);
    idx = sub2ind(siz, Pt(1, :), Pt(2, :));
    ST(idx) = 1;
    ST = double(ST);

    %% each level
    for iL = 1 : nL
        th = ths(iL);
        [Pre(iL, iF), Rec(iL, iF), ~, ~, Fc(iL, iF)] = calculate_classification_scores_mex(S, ST, th, mask_threshold, 1, pr_div_by_zero_result);
        
        beta = .3;
        Fc(iL, iF) = (1 + beta) * Pre(iL, iF) * Rec(iL, iF) / (beta * Pre(iL, iF) + Rec(iL, iF));
    end
end
prCOut(nF);

% store
wsEva.prex = prex;
wsEva.subx = subx;
wsEva.Pre = Pre;
wsEva.Rec = Rec;
wsEva.Fc = Fc;

% save
if svL
    save(matpath, 'wsEva');
end

prOut;
