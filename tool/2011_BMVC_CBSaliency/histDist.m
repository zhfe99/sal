function dist = histDist(h1, h2)
% Compute distance between histograms.

% normalize
h1 = h1 / (sum(h1(:)) + eps);
h2 = h2 / (sum(h2(:)) + eps);

dist = sum((h1 - h2) .^ 2 ./ (h2 + h1 + eps)) / 2;
