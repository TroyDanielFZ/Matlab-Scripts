%=============================================================================
%     FileName: tsubplot.m
%         Desc: like subplot, but with the margin and gap being very small
%       Author: Troy Daniel
%        Email: Troy_Daniel@163.com
%     HomePage: https://www.cnblogs.com/troy-daniel
%      Version: 0.0.2
%   LastChange: 2021-06-14 19:18:53
%      History:
% Ver 0.0.1     2021-06-14
%				Initial delivery
% Ver 0.0.2     2021-06-14
% 				Return the Axes, if the bounding box are very close to the desired one
%=============================================================================
function h = tsubplot(varargin)
	% Ver 0.0.1
	%  +---------+---------+---------+
	%  |    1    |     2   |    3    |
	%  +---------+---------+---------+
	%  |    4    |     5   |    6    |
	%  +---------+---------+---------+
	%  |    7    |     8   |    9    |
	%  +---------+---------+---------+
    if nargin >= 3, nRow = varargin{1}, nCol = varargin{2}, nIndex = varargin{3}; end
	if nargin == 2, error("Calling with two input args is not supported"), end
	if nargin == 1
		if varargin{1} < 100 || varargin{1} > 999
			error("Invaild calling with one parameters");
		end
		nRow = floor(varargin{1} / 100);
		nCol = floor(mod(varargin{1}, 100) / 10);
		nIndex = mod(varargin{1}, 10);
		if nIndex > (nRow * nCol)
			error("Invaild calling with one parameters");
		end
	end

	margin = 0.01;
	gap = 0.01;
	%     +------------------------------------------------------------------+
	%     |          margin                           margin                 |
	%     | m +------------------------+        +------------------------+ m |     +
	%     | a |         1              |   gap  |          2             | a |     | h
	%     | r +------------------------+        +------------------------+ r |     +
	%     | g      gap                                 gap                 g |
	%     | i +------------------------+        +------------------------+ i |
	%     | n |         3              |        |          4             | n |
	%     |   +------------------------+        +------------------------+   |
	%     |          margin                           margin                 |
	%     +------------------------------------------------------------------+
	%         +------------------------+
	%              w
	w = (1-margin * 2 - gap * (nCol - 1)) / nCol;
	h = (1-margin * 2 - gap * (nRow - 1)) / nRow;

	cols = mod(nIndex-1, nCol) + 1;
	colMin = min(cols);
	colSpan = max(cols) - colMin + 1;
	% colMax = max(cols);
	rows = floor((nIndex-1)/nCol) + 1;
	rowMin = min(rows);
	rowSpan = max(rows) - rowMin + 1;
	rowMax = max(rows);

	outPosition =  [margin + (colMin-1) * (w + gap), ...
			margin + (nRow - rowMax) * (h + gap), ...
			w * colSpan + gap * (colSpan - 1), ...
			h * rowSpan + gap * (rowSpan - 1)];
	% h = axes('Units','normalized', ...
	% 	'OuterPosition', [margin + (colMin-1) * (w + gap), ...
	% 		margin + (nRow - rowMax) * (h + gap), ...
	% 		w * colSpan + gap * (colSpan - 1), ...
	% 		h * rowSpan + gap * (rowSpan - 1)]);

	% remove axes that was covered by this axis
	tolerance = 0.01;
	outRect = [outPosition(1:2) - tolerance, outPosition(1:2) + outPosition(3:4) + tolerance];
	fig = gcf;
	nLength = length(fig.Children);
	for idx = nLength:-1:1
		hAxes = fig.Children(idx);
		if class(hAxes) == "matlab.graphics.axis.Axes"
			%  if the bounding box differ no more than tolerance, treat it as the desired axes
			if all(abs(hAxes.OuterPosition(1:2)- outPosition(1:2)) < tolerance) && all(abs(hAxes.OuterPosition(3:4) + hAxes.OuterPosition(1:2) - (outPosition(3:4) + outPosition(1:2)))< tolerance) 
                axes(hAxes); % make this the current active one
				h = hAxes;
				return;
			end
			if all(hAxes.Position(1:2)> outRect(1:2)) && all(hAxes.Position(3:4) + hAxes.Position(1:2) < outRect(3:4))
				delete(hAxes);
			end
		end
	end
	h = axes('Units','normalized', 'OuterPosition', outPosition);
    set(h,'LooseInset',get(h,'TightInset'));   % Please refer to: https://undocumentedmatlab.com/articles/axes-looseinset-property
end
