function pos = maxpos(vect, n)
% pos = maxpos(vect, n);
%
% return indices of n highest values in
% vector vect

if ~exist('n', 'var')
    n = 1;
end

[~, p] = max(vect);
pos = p;
if n > 1
    mn = min(vect);
    for i = 1:n-1
    vect(p) = mn;
    [~, p] = max(vect);
    pos = [pos, p];
    end
end



