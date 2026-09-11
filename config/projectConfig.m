function config = projectConfig()
%PROJECTCONFIG Central configuration for SIH PS38 DR Screening.
%
% Returns a structure containing project-wide settings.

% Project root
config.projectRoot = fileparts(fileparts(mfilename('fullpath')));

% Dataset locations
config.data.aptos = fullfile(config.projectRoot, 'data', 'aptos');
config.data.idrid = fullfile(config.projectRoot, 'data', 'idrid');
config.data.drive = fullfile(config.projectRoot, 'data', 'drive');
config.data.messidor2 = fullfile(config.projectRoot, 'data', 'messidor2');

% DR classification
config.classification.numClasses = 5;
config.classification.classNames = { ...
    'No DR', ...
    'Mild NPDR', ...
    'Moderate NPDR', ...
    'Severe NPDR', ...
    'Proliferative DR'};

% Project definition of referable DR
config.classification.referableThreshold = 2;

% Standard image size for initial prototype
config.image.inputSize = [224 224 3];
end
