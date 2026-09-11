function feedback = recaptureFeedback(qualityResult)
% recaptureFeedback Generate actionable feedback for poor-quality images.
%
% Input:
%   qualityResult - output structure from assessQuality
%
% Output:
%   feedback - structure containing feedback messages

    messages = strings(0,1);

    % Prototype thresholds
    focusThreshold = 0.40;
    illuminationThreshold = 0.40;
    fovThreshold = 0.50;

    % Check focus
    if qualityResult.focusNormalized < focusThreshold
        messages(end+1,1) = ...
            "Image appears poorly focused. Hold the camera steady and refocus.";
    end

    % Check illumination
    if qualityResult.illuminationNormalized < illuminationThreshold
        messages(end+1,1) = ...
            "Image illumination is insufficient. Ensure adequate and even lighting.";
    end

    % Check field of view
    if qualityResult.fovNormalized < fovThreshold
        messages(end+1,1) = ...
            "Retinal field of view is incomplete. Center the eye and capture the retina fully.";
    end

    % If no specific problem was detected
    if isempty(messages)
        messages(end+1,1) = ...
            "Image quality is insufficient. Please recapture the fundus image.";
    end

    % General instructions
    instructions = [
        "Keep the camera steady."
        "Center the eye in the camera view."
        "Avoid excessive glare or reflections."
        "Ensure the retina is clearly visible."
        ];

    % Return structured feedback
    feedback.messages = messages;
    feedback.instructions = instructions;

    % Create a single summary string
    allMessages = [
        "Image quality is insufficient."
        messages
        "Please capture the image again after correcting the above issues."
        ];

    feedback.summary = join(allMessages, newline);
end