function roiPosCallbackStats(pos, I, ROINum, hTable)
J = imcrop(I, pos);

fmt = '%.2f';
ThisMean = sprintf(fmt, mean2(J));
ThisStd = sprintf(fmt, std2(J));
ThisMin = sprintf(fmt, double(min(J(:))));
ThisMax = sprintf(fmt, double(max(J(:))));
ThisEntropy = sprintf(fmt, entropy(J));

hTable.Data{1,ROINum} = ThisMean;
hTable.Data{2,ROINum} = ThisStd;
hTable.Data{3,ROINum} = ThisMin;
hTable.Data{4,ROINum} = ThisMax;
hTable.Data{5,ROINum} = ThisEntropy;
