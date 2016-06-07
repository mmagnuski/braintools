function [clst, col] = color_clusters(clst, color)

% currently uses predefined colors... :(
% FIXHELPINFO
if ~exist('color', 'var') || isempty(color)
    col = zeros(length(clst), 3);
    pn = [false, false];
    clst_col = [0, 0, 0; 0.4, 0.4, 0.4; ...
           1, 1, 1; 0.85, 0.85, 0.85];
    pn = [false, false];

    for c = 1:length(clst)
        if strcmp(clst(c).pol, 'pos')
            if pn(1)
                col(c,:) = clst_col(2,:);
            else
                col(c,:) = clst_col(1,:);
                pn(1) = true;
            end
        else
           if pn(2)
                col(c,:) = clst_col(4,:);
            else
                col(c,:) = clst_col(3,:);
                pn(2) = true;
            end
        end
        clst(c).color = col(c, :);
    end
else
    for c = 1:size(color, 1)
        clst(c).color = color(c, :);
    end
end
