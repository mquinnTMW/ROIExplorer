function roiPosCallbackHistogram(pos, I, hLine)
J = imcrop(I, pos);
[C, B] = imhist(J);
C = C/numel(J);
set(hLine, 'XData', B);
set(hLine, 'YData', C);
axis(hLine.Parent, 'tight');

% plo
% M = mean2(J);
% S = std2(J);
% MN = double(min(J(:)));
% MX = double(max(J(:)));
% E = entropy(J);
% 
% fprintf('---------------------\n');
% fprintf('[Min, Max]: [%.2f, %.2f]\n', MN, MX);
% fprintf('Mean: %.2f\n', M);
% fprintf('Std: %.2f\n', S);
% fprintf('Entropy: %.2f\n', E);
% 
% 
