function score = illuminationScore(image)
% illuminationScore Calculate an illumination score.
%
% Input:
%   image - RGB or grayscale fundus image
%
% Output:
%   score - mean grayscale brightness

grayImage = im2gray(image);

score = mean(double(grayImage(:)));
end