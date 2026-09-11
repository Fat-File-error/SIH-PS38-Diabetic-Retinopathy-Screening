function demoDRScreening
% demoDRScreening
% SIH PS38 - Judge-facing Diabetic Retinopathy screening demo

clc;
close all;

%% PROJECT SETUP

projectRoot = "/Users/adityaraghuwanshi/sih 2026/SIH_PS38_DR_Screening";

addpath(genpath(fullfile(projectRoot,"src")));

modelPath = fullfile( ...
    projectRoot, ...
    "models", ...
    "dr_classifier", ...
    "drClassifier.mat");

%% HEADER

fprintf("\n============================================\n");
fprintf("     SIH PS38 - AI FUNDUS SCREENING\n");
fprintf("============================================\n");

%% SELECT IMAGE

[file, location] = uigetfile( ...
    {'*.jpg;*.jpeg;*.png;*.tif;*.tiff', ...
     'Fundus Images'; ...
     '*.*', 'All Files'}, ...
    'Select Fundus Image');

if isequal(file,0)
    fprintf("\nNo image selected.\n");
    return;
end

imagePath = fullfile(location,file);

img = imread(imagePath);

fprintf("\nSelected Image: %s\n",file);
fprintf("Image Size: %d x %d\n",size(img,1),size(img,2));

%% STEP 1 - IMAGE QUALITY

fprintf("\n--------------------------------------------\n");
fprintf("STEP 1: IMAGE QUALITY ASSESSMENT\n");
fprintf("--------------------------------------------\n");

qualityResult = assessQuality(img);

fprintf("Focus Score       : %.4f\n", ...
    qualityResult.focusScore);

fprintf("Illumination Score: %.4f\n", ...
    qualityResult.illuminationScore);

fprintf("FOV Score         : %.4f\n", ...
    qualityResult.fovScore);

fprintf("Overall Quality   : %.4f\n", ...
    qualityResult.overallScore);

%% QUALITY DECISION

if qualityResult.isGradable

    fprintf("\n✓ IMAGE ACCEPTED\n");
    fprintf("Proceeding to DR classification.\n");

else

    fprintf("\n✗ IMAGE REJECTED\n");

    feedback = recaptureFeedback(qualityResult);

    fprintf("\nRECAPTURE FEEDBACK:\n");
    fprintf("%s\n",feedback.summary);

    % Show rejected image
    figure("Name","SIH PS38 - Image Quality","NumberTitle","off");

    imshow(img);
    title("Image rejected - Please recapture");

    return;
end

%% STEP 2 - PREPROCESSING

fprintf("\n--------------------------------------------\n");
fprintf("STEP 2: IMAGE PREPROCESSING\n");
fprintf("--------------------------------------------\n");

inputSize = [227 227 3];

inputImage = imresize(img,inputSize(1:2));

fprintf("Original image : %d x %d\n", ...
    size(img,1),size(img,2));

fprintf("Model input    : %d x %d x %d\n", ...
    inputSize(1),inputSize(2),inputSize(3));

fprintf("✓ Image resized for neural network.\n");

%% STEP 3 - LOAD MODEL

fprintf("\n--------------------------------------------\n");
fprintf("STEP 3: DEEP LEARNING CLASSIFICATION\n");
fprintf("--------------------------------------------\n");

if ~isfile(modelPath)

    fprintf("\nERROR: DR classifier model not found.\n");
    fprintf("Expected model:\n%s\n",modelPath);
    return;

end

load(modelPath,"net");

fprintf("✓ Trained DR classifier loaded.\n");

%% STEP 4 - PREDICTION

inputForNetwork = single(inputImage);

scores = predict(net,inputForNetwork);

scores = extractdata(scores);
scores = squeeze(scores);

scores = scores ./ sum(scores);

[confidence,index] = max(scores);

%% DR CLASS NAMES

classNames = [ ...
    "No DR", ...
    "Mild NPDR", ...
    "Moderate NPDR", ...
    "Severe NPDR", ...
    "Proliferative DR"];

predictedClass = classNames(index);

grade = index - 1;

fprintf("\nMODEL OUTPUT:\n");

fprintf("Predicted Grade : %d\n",grade);
fprintf("DR Class        : %s\n",predictedClass);
fprintf("Confidence      : %.2f%%\n", ...
    confidence*100);

%% STEP 5 - REFERABLE DR

fprintf("\n--------------------------------------------\n");
fprintf("STEP 4: REFERABLE DR DECISION\n");
fprintf("--------------------------------------------\n");

if grade >= 2

    referable = true;

    fprintf("⚠ REFERABLE DR DETECTED\n");
    fprintf("Project rule: Grade >= 2\n");

else

    referable = false;

    fprintf("✓ NO REFERABLE DR\n");
    fprintf("Project rule: Grade < 2\n");

end

%% FINAL CONSOLE SUMMARY

fprintf("\n============================================\n");
fprintf("              FINAL RESULT\n");
fprintf("============================================\n");

fprintf("DR Grade       : %d - %s\n", ...
    grade,predictedClass);

fprintf("Confidence     : %.2f%%\n", ...
    confidence*100);

if referable
    fprintf("Referable DR   : YES\n");
else
    fprintf("Referable DR   : NO\n");
end

fprintf("============================================\n");

%% FINAL VISUAL DEMO

fig = figure( ...
    "Name","SIH PS38 - AI Diabetic Retinopathy Screening", ...
    "NumberTitle","off", ...
    "Color","white", ...
    "Position",[80 80 1400 850]);

tiledlayout(fig,2,3, ...
    "TileSpacing","compact", ...
    "Padding","compact");

%% 1. INPUT IMAGE

nexttile;

imshow(img);

title("1. INPUT FUNDUS IMAGE", ...
    "FontSize",15, ...
    "FontWeight","bold", ...
    "Interpreter","none");

%% 2. QUALITY ASSESSMENT

nexttile;

imshow(img);

title("2. IMAGE QUALITY ASSESSMENT", ...
    "FontSize",15, ...
    "FontWeight","bold", ...
    "Interpreter","none");

%% 3. NEURAL NETWORK INPUT

nexttile;

imshow(inputImage);

title("3. NEURAL NETWORK INPUT", ...
    "FontSize",15, ...
    "FontWeight","bold", ...
    "Interpreter","none");

%% 4. QUALITY DETAILS

nexttile;

axis off;

text(0.05,0.92,"IMAGE QUALITY", ...
    "Units","normalized", ...
    "FontSize",18, ...
    "FontWeight","bold", ...
    "Color","black", ...
    "Interpreter","none");

text(0.05,0.72, ...
    "Focus       : " + string(round(qualityResult.focusNormalized,3)), ...
    "Units","normalized", ...
    "FontSize",14, ...
    "Color","black", ...
    "Interpreter","none");

text(0.05,0.57, ...
    "Illumination: " + string(round(qualityResult.illuminationNormalized,3)), ...
    "Units","normalized", ...
    "FontSize",14, ...
    "Color","black", ...
    "Interpreter","none");

text(0.05,0.42, ...
    "FOV         : " + string(round(qualityResult.fovNormalized,3)), ...
    "Units","normalized", ...
    "FontSize",14, ...
    "Color","black", ...
    "Interpreter","none");

text(0.05,0.27, ...
    "Overall     : " + string(round(qualityResult.overallScore*100,1)) + " %", ...
    "Units","normalized", ...
    "FontSize",14, ...
    "FontWeight","bold", ...
    "Color","black", ...
    "Interpreter","none");

text(0.05,0.12, ...
    "Gradable    : YES", ...
    "Units","normalized", ...
    "FontSize",15, ...
    "FontWeight","bold", ...
    "Color","black", ...
    "Interpreter","none");

%% 5. AI CLASSIFICATION

nexttile;

bar(scores*100);

ylim([0 100]);

xticks(1:5);

xticklabels({ ...
    "Grade 0", ...
    "Grade 1", ...
    "Grade 2", ...
    "Grade 3", ...
    "Grade 4"});

ylabel("Probability (%)");

title("4. AI CLASSIFICATION", ...
    "FontSize",15, ...
    "FontWeight","bold", ...
    "Interpreter","none");

grid on;

%% 6. FINAL RESULT

nexttile;

axis off;

text(0.05,0.90,"FINAL SCREENING RESULT", ...
    "Units","normalized", ...
    "FontSize",18, ...
    "FontWeight","bold", ...
    "Color","black", ...
    "Interpreter","none");

text(0.05,0.68, ...
    "DR GRADE " + string(grade), ...
    "Units","normalized", ...
    "FontSize",24, ...
    "FontWeight","bold", ...
    "Color","black", ...
    "Interpreter","none");

text(0.05,0.52, ...
    predictedClass, ...
    "Units","normalized", ...
    "FontSize",19, ...
    "FontWeight","bold", ...
    "Color","black", ...
    "Interpreter","none");

text(0.05,0.35, ...
    "Confidence: " + string(round(confidence*100,2)) + " %", ...
    "Units","normalized", ...
    "FontSize",16, ...
    "FontWeight","bold", ...
    "Color","black", ...
    "Interpreter","none");

if referable

    decisionText = "REFERABLE DR";

else

    decisionText = "NO REFERABLE DR";

end

text(0.05,0.17, ...
    decisionText, ...
    "Units","normalized", ...
    "FontSize",18, ...
    "FontWeight","bold", ...
    "Color","black", ...
    "Interpreter","none");

%% FINAL CONSOLE MESSAGE

fprintf("\n============================================\n");
fprintf("       SCREENING COMPLETED SUCCESSFULLY\n");
fprintf("============================================\n");

end