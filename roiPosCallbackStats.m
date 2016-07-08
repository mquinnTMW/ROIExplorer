function roiPosCallbackStats(pos, I, ROINum, hTable)
%
% roiPosCallbackStats
%
% This callback function updates the statistics table when the ROI (which
% is an imrect object) is moved or resized.
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

% Set the display format
fmt = '%.2f';

% Compute the statistics and format as string
ThisMean = sprintf(fmt, mean2(J));
ThisStd = sprintf(fmt, std2(J));
ThisMin = sprintf(fmt, double(min(J(:))));
ThisMax = sprintf(fmt, double(max(J(:))));
ThisEntropy = sprintf(fmt, entropy(J));

% Place the new data into the table
hTable.Data{1,ROINum} = ThisMean;
hTable.Data{2,ROINum} = ThisStd;
hTable.Data{3,ROINum} = ThisMin;
hTable.Data{4,ROINum} = ThisMax;
hTable.Data{5,ROINum} = ThisEntropy;
