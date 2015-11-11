function pnts = circle(x, y, r, varargin)

% returns n x 2 matrix containing x,y coordinates
% of points equally positioned on a circle with 
% x, y center and r radius.
%
% input
% -----
% x, y - circle center
% r    - radius
%
% optional arguments
% ------------------
% 'n' - number of points on the circle
%
% output
% ------
% pnts - n x 2 matrix with n points and their x, y
%        coordinates

opt.n = 16;
if ~isempty(varargin)
    opt = parse_arse(varargin, opt);
end

fin = 2*pi;
step = fin / opt.n;
ang = 0:step:fin; 
pnts = [x + r * cos(ang); y + r * sin(ang)]';