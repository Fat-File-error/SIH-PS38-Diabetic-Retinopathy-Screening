function score = focusScore(image)
% focusScore Calculate a simple sharpness/focus score.
%
% Input:
%   image - RGB or grayscale fundus image
%
% Output:
%   score - mean gradient magnitude

grayImage = im2gray(image);

[Gmag, ~] = imgradient(grayImage);

score = mean(Gmag(:));
end