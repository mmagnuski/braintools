function varargout = cluster_from_folders(pth, chanconn, effect_name, varargin)

% stat = cluster_from_folders(pth, chanconn, effect_name)
% CLUSTER_FROM_FOLDERS clusters data scattered across permutation folders


% dirnames:
ls = dir(pth);
dirs = ls([ls.isdir]);
nums = regexp({dirs.name}, '[0-9]+', 'match', 'once');
nums = nums(~cellfun(@isempty, nums));
num_perm = max(cellfun(@str2num, nums));

% TODO - read effect names from formula
%        in the dir if present
num_effects = length(effect_name);

% prepare pos and neg distrib
posdist = zeros(num_perm, num_effects);
negdist = zeros(num_perm, num_effects);


% channels used in the model:
elec = cell(62,1);
el = 1:64;
el([62, 63]) = [];
for e = 1:62
    elec{e} = ['E', num2str(el(e))];
end

% Holmes
opt.holmes = false;
if ~isempty(varargin)
    opt = parse_arse(varargin, opt);
end
if opt.holmes
    h_stat = cell(num_effects, 1);
end
stat = cell(num_effects, 1);

% cluster permutations
% --------------------
holmes_iter = 0;
holmes_continue = true;
any_significant = true(num_effects, 1);

while holmes_continue
    holmes_iter = holmes_iter + 1;
    for n = 1:num_perm
        data = read_model_data(fullfile(pth, ['perm', num2str(n)]), ...
            elec);
        
        for ef = 1:num_effects
            
            if any_significant(ef)
                % Holmes correction
                if opt.holmes && holmes_iter > 1
                    data{ef}(h_stat{ef}.mask) = 0;
                end
                [posdist(n, ef), negdist(n, ef)] = ...
                    cluster_this(data{ef}, 2, chanconn);
            end
        end
        if opt.holmes
            fprintf('holmes iteration %d, permutation %d\n', holmes_iter, n);
        else
            fprintf('%d\n', n);
        end
    end
    
    % read actual effect:
    data = read_model_data(fullfile(pth, 'perm0'), elec);
    
    % cluster effects
    for ef = find(any_significant)'
        % Holmes correction
        if opt.holmes && holmes_iter > 1
            data{ef}(h_stat{ef}.mask) = 0;
        end
        
        stat{ef} = cluster_main(data{ef}, chanconn, ...
            posdist(:,ef), negdist(:,ef));
        
        if opt.holmes
            % check for positive and negative significant clusters:
            [h_stat{ef}, any_significant(ef)] = holmes_correct(stat{ef}, ...
                h_stat{ef});
        end
    end
    if opt.holmes
        holmes_continue = any(any_significant);
    else
        holmes_continue = false;
    end
end
% [stat.effect] = deal(effect_name{:});
if opt.holmes
    varargout{1} = h_stat;
    varargout{2} = stat;
else
    varargout{1} = stat;
end