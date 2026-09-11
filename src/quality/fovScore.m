function [score, details] = fovScore(image)
% fovScore Estimate the visible retinal field of view.
%
% Inputs:
%   image - RGB or grayscale fundus image
%
% Outputs:
%   score   - detected FOV coverage, normalized from 0 to 1
%   details - additional FOV measurements

% Convert to grayscale
grayImage = im2gray(image);

% Reduce resolution for faster processing
graySmall = imresize(grayImage, 0.25);

% Segment the main foreground region
fovMask = imbinarize(graySmall);

% Remove very small regions
fovMask = bwareaopen(fovMask, 500);

% Find connected components
cc = bwconncomp(fovMask);

% Handle case where nothing is detected
if cc.NumObjects == 0
    score = 0;

    details.coverage = 0;
    details.largestRegionFraction = 0;
    details.extent = 0;
    details.centroid = [NaN NaN];
    details.boundingBox = [NaN NaN NaN NaN];

    return
end

% Measure connected components
stats = regionprops(cc, ...
    "Area", ...
    "BoundingBox", ...
    "Centroid", ...
    "Extent");

% Find largest connected region
areas = [stats.Area];
[largestArea, largestIndex] = max(areas);

largestStats = stats(largestIndex);

% Calculate total image area
totalPixels = numel(fovMask);

% FOV coverage
coverage = largestArea / totalPixels;

% Store outputs
score = coverage;

details.coverage = coverage;
details.largestRegionFraction = largestArea / sum(areas);
details.extent = largestStats.Extent;
details.centroid = largestStats.Centroid;
details.boundingBox = largestStats.BoundingBox;
end
