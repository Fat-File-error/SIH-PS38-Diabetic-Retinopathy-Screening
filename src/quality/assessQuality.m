function qualityResult = assessQuality(image)
% assessQuality Perform overall fundus image quality assessment.
%
% Input:
%   image - RGB or grayscale fundus image
%
% Output:
%   qualityResult - structure containing quality measurements
%
% NOTE:
% The current thresholds are prototype calibration values.
% They are NOT clinically validated thresholds.

% Calculate individual quality features
focus = focusScore(image);
illumination = illuminationScore(image);
[fov, fovDetails] = fovScore(image);

% Store raw measurements
qualityResult.focusScore = focus;
qualityResult.illuminationScore = illumination;
qualityResult.fovScore = fov;

% Store additional FOV information
qualityResult.fovDetails = fovDetails;

% ---------------------------------------------------------
% Prototype normalization
% ---------------------------------------------------------
%
% These values are temporary calibration ranges.
% We will later calibrate them using multiple images.

focusMin = 2;
focusMax = 10;

illuminationMin = 20;
illuminationMax = 100;

fovMin = 0.40;
fovMax = 0.80;

% Normalize each feature to approximately 0-1
focusNormalized = ...
    (focus - focusMin) / (focusMax - focusMin);

illuminationNormalized = ...
    (illumination - illuminationMin) / ...
    (illuminationMax - illuminationMin);

fovNormalized = ...
    (fov - fovMin) / ...
    (fovMax - fovMin);

% Keep values within 0-1
focusNormalized = min(max(focusNormalized,0),1);
illuminationNormalized = min(max(illuminationNormalized,0),1);
fovNormalized = min(max(fovNormalized,0),1);

% Store normalized values
qualityResult.focusNormalized = focusNormalized;
qualityResult.illuminationNormalized = illuminationNormalized;
qualityResult.fovNormalized = fovNormalized;

% Overall prototype quality score
qualityResult.overallScore = ...
    0.40 * focusNormalized + ...
    0.30 * illuminationNormalized + ...
    0.30 * fovNormalized;

% Prototype gradability decision
qualityResult.isGradable = ...
    qualityResult.overallScore >= 0.50;

% Generate feedback
if qualityResult.isGradable
    qualityResult.feedback = ...
        "Image quality acceptable. Proceed with analysis.";
else
    qualityResult.feedback = ...
        "Image quality insufficient. Please recapture the fundus image.";
end
end
