function roiPosCallbackHistogram(pos, I, hLine)
%
% roiPosCallbackHistogram
%
% This callback function updates the histogram when the ROI (which is an
% imrect object) is moved or resized.
%
% Written by Michael Quinn, PhD
% michael.quinn@mathworks.com
% 2016/04/27
%
%
% version 1.0
% 2016/04/27
% Initial release
%
%

% Copyright 2016 The MathWorks, Inc.

% Crop out this ROI
J = imcrop(I, pos);

% Compute the histogram
[C, B] = imhist(J);

% Normalize the histogram
C = C/numel(J);

% Update the histogram plot with the new data
set(hLine, 'XData', B);
set(hLine, 'YData', C);

% Tighten the axes
axis(hLine.Parent, 'tight');