function pos = minpos(vect, n)

if ~exist('n', 'var')
    n = 1;
end

[~, p] = min(vect);
pos = p;
if n > 1
    mx = max(vect);
    for i = 1:n-1
    vect(p) = mx;
    [~, p] = min(vect);
    pos = [pos, p];
    end
end



