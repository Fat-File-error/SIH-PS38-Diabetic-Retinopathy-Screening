%% SIH PS38 - Single Fundus Image Screening Demo
% This script allows you to select one fundus image and run
% the modules that are currently available.

clc;
clear;
close all;

%% ---------------------------------------------------------
% 1. SET PROJECT PATHS
% ----------------------------------------------------------

projectRoot = "/Users/adityaraghuwanshi/sih 2026/SIH_PS38_DR_Screening";

addpath(genpath(fullfile(projectRoot, "src")));

%% ---------------------------------------------------------
% 2. SELECT FUNDUS IMAGE
% ----------------------------------------------------------

[fileName, filePath] = uigetfile( ...
    {'*.jpg;*.jpeg;*.png;*.tif;*.tiff', ...
     'Fundus Images (*.jpg, *.jpeg, *.png, *.tif, *.tiff)'}, ...
    'Select a Fundus Image');

% User cancelled
if isequal(fileName, 0)
    disp("No image selected.");
    return;
end

imagePath = fullfile(filePath, fileName);

%% ---------------------------------------------------------
% 3. READ IMAGE
% ----------------------------------------------------------

img = imread(imagePath);

fprintf("\n============================================\n");
fprintf(" SIH PS38 - FUNDUS SCREENING DEMO\n");
fprintf("============================================\n");

fprintf("\nImage: %s\n", fileName);

fprintf("Image size: ");
disp(size(img));

%% ---------------------------------------------------------
% 4. DISPLAY ORIGINAL IMAGE
% ----------------------------------------------------------

figure("Name","Fundus Screening","NumberTitle","off");

imshow(img);
title("Input Fundus Image");

%% ---------------------------------------------------------
% 5. IMAGE QUALITY ASSESSMENT
% ----------------------------------------------------------

fprintf("\n--------------------------------------------\n");
fprintf(" IMAGE QUALITY ASSESSMENT\n");
fprintf("--------------------------------------------\n");

qualityResult = assessQuality(img);

fprintf("Focus Score          : %.4f\n", ...
    qualityResult.focusScore);

fprintf("Illumination Score   : %.4f\n", ...
    qualityResult.illuminationScore);

fprintf("FOV Score            : %.4f\n", ...
    qualityResult.fovScore);

fprintf("Overall Quality      : %.4f\n", ...
    qualityResult.overallScore);

fprintf("Gradable             : %s\n", ...
    string(qualityResult.isGradable));

%% ---------------------------------------------------------
% 6. QUALITY DECISION
% ----------------------------------------------------------

if qualityResult.isGradable

    fprintf("\nQUALITY STATUS:\n");
    fprintf("✓ Image quality acceptable.\n");
    fprintf("  Proceeding to further analysis.\n");

else

    fprintf("\nQUALITY STATUS:\n");
    fprintf("✗ Image quality insufficient.\n");

    feedback = recaptureFeedback(qualityResult);

    fprintf("\nRECAPTURE FEEDBACK:\n");
    fprintf("%s\n", feedback.summary);

end

%% ---------------------------------------------------------
% 7. SHOW QUALITY DETAILS
% ----------------------------------------------------------

fprintf("\n--------------------------------------------\n");
fprintf(" QUALITY DETAILS\n");
fprintf("--------------------------------------------\n");

fprintf("Focus normalized        : %.4f\n", ...
    qualityResult.focusNormalized);

fprintf("Illumination normalized : %.4f\n", ...
    qualityResult.illuminationNormalized);

fprintf("FOV normalized          : %.4f\n", ...
    qualityResult.fovNormalized);

%% ---------------------------------------------------------
% 8. DR CLASSIFICATION
% ----------------------------------------------------------
%
% IMPORTANT:
% We currently have NOT trained the DR classifier.
%
% This section checks whether a trained model exists.
%
% Expected future file:
%
% models/dr_classifier/drClassifier.mat
%
% containing:
%   net
%
% Once we train the classifier, this section will automatically
% start producing DR predictions.

fprintf("\n--------------------------------------------\n");
fprintf(" DR CLASSIFICATION\n");
fprintf("--------------------------------------------\n");

modelPath = fullfile( ...
    projectRoot, ...
    "models", ...
    "dr_classifier", ...
    "drClassifier.mat");

if isfile(modelPath)

    fprintf("Trained DR model found.\n");

    load(modelPath, "net");

    % Five DR classes
    classNames = categorical([ ...
        "No DR"
        "Mild NPDR"
        "Moderate NPDR"
        "Severe NPDR"
        "Proliferative DR"
        ]);

    % SqueezeNet input size
    inputSize = net.Layers(1).InputSize;

    % Resize image
    inputImage = imresize(img, inputSize(1:2));

    % Convert to single precision
    inputImage = single(inputImage);

    % Predict
    scores = predict(net, inputImage);

    % Convert scores to probabilities
    scores = extractdata(scores);

    scores = squeeze(scores);

    % Normalize if necessary
    scores = scores ./ sum(scores);

    % Find highest probability
    [confidence, index] = max(scores);

    predictedClass = classNames(index);

    fprintf("\nPREDICTION:\n");
    fprintf("DR Grade              : %s\n", ...
        string(predictedClass));

    fprintf("Confidence            : %.2f%%\n", ...
        confidence * 100);

    %% Show class probabilities

    fprintf("\nCLASS PROBABILITIES:\n");

    for i = 1:numel(classNames)

        fprintf("Grade %d - %-20s : %.2f%%\n", ...
            i-1, ...
            string(classNames(i)), ...
            scores(i) * 100);

    end

    %% Referable DR

    gradeIndex = index - 1;

    if gradeIndex >= 2

        fprintf("\nREFERABLE DR:\n");
        fprintf("⚠ REFERABLE DR DETECTED\n");
        fprintf("Ophthalmology referral recommended.\n");

    else

        fprintf("\nREFERABLE DR:\n");
        fprintf("✓ No referable DR according to project rule.\n");

    end

else

    fprintf("\n⚠ DR classifier has NOT been trained yet.\n");
    fprintf("Classification will be enabled after training.\n");

end

%% ---------------------------------------------------------
% 9. MODULE STATUS
% ----------------------------------------------------------

fprintf("\n============================================\n");
fprintf(" MODULE STATUS\n");
fprintf("============================================\n");

fprintf("✓ Image Quality Assessment\n");

if qualityResult.isGradable
    fprintf("✓ Image passed prototype quality check\n");
else
    fprintf("⚠ Image failed prototype quality check\n");
end

fprintf("✓ Recapture feedback\n");

if isfile(modelPath)
    fprintf("✓ DR classification\n");
else
    fprintf("○ DR classification - training pending\n");
end

fprintf("○ Blood vessel segmentation - training pending\n");
fprintf("○ Lesion detection - training pending\n");
fprintf("○ Grad-CAM explainability - training pending\n");
fprintf("○ Clinical report generation - pending\n");

fprintf("\n============================================\n");
fprintf(" END OF SCREENING\n");
fprintf("============================================\n");