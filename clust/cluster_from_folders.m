function varargout = cluster_from_folders(pth, chanconn, effect_name, varargin)

% stat = cluster_from_folders(pth, chanconn, effect_name)
% CLUSTER_FROM_FOLDERS clusters data scattered across permutation folders


% dirnames:
lst = dir(pth);
dirs = lst([lst.isdir]);
nums = regexp({dirs.name}, '[0-9]+', 'match', 'once');
nums = nums(~cellfun(@isempty, nums));
if ~isempty(nums)
    % electrode csv are scattered in folders
    indir = true;
    nums = cellfun(@str2num, nums);
else
    % each permutation is a separate .mat file
    indir = false;
    [~, tok] = regexp({lst.name}, 'perm([0-9]+)\.mat', 'match', 'once', 'tokens');
    isok = ~cellfun(@isempty, tok);
    nums = cellfun(@(x) str2double(x{1}), tok(isok));
end


% TODO - read effect names from formula
%        in the dir if present
num_perm = max(nums);
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

% Holms
opt.holms = false;
if ~isempty(varargin)
    opt = parse_arse(varargin, opt);
end
if opt.holms
    h_stat = cell(num_effects, 1);
end
stat = cell(num_effects, 1);

% cluster permutations
% --------------------
holms_iter = 0;
holms_continue = true;
any_significant = true(num_effects, 1);

while holms_continue
    holms_iter = holms_iter + 1;
    for n = 1:num_perm
        if indir
        data = read_model_data(fullfile(pth, ['perm', num2str(n)]), ...
            elec);
        else
            data = load(fullfile(pth, sprintf('perm%d.mat', n)));
            data = data.zs;
            data = permute(data, [3, 2, 1]);
            data = mat2cell(data, size(data,1), size(data,2), ...
                ones(size(data,3), 1));
        end
        
        for ef = 1:num_effects
            
            if any_significant(ef)
                % holms correction
                if opt.holms && holms_iter > 1
                    data{ef}(h_stat{ef}.mask) = 0;
                end
                [posdist(n, ef), negdist(n, ef)] = ...
                    cluster_this(data{ef}, 2, chanconn);
            end
        end
        if opt.holms
            tx = sprintf('holms iteration %d, permutation %d\n', ...
                holms_iter, n);
        else
            fprintf('%d\n', n);
        end
    end
    
    % read actual effect:
    if indir
        data = read_model_data(fullfile(pth, 'perm0'), elec);
    else
        data = load(fullfile(pth, 'perm0.mat'));
        data = data.zs;
        data = permute(data, [3, 2, 1]);
        data = mat2cell(data, size(data,1), size(data,2), ...
            ones(size(data,3), 1));
    end
    
    % cluster effects
    for ef = find(any_significant)'
        % holms correction
        if opt.holms && holms_iter > 1
            data{ef}(h_stat{ef}.mask) = 0;
        end
        
        stat{ef} = cluster_main(data{ef}, chanconn, ...
            posdist(:,ef), negdist(:,ef));
        
        if opt.holms
            % check for positive and negative significant clusters:
            [h_stat{ef}, any_significant(ef)] = holms_correct(stat{ef}, ...
                h_stat{ef});
        end
    end
    if opt.holms
        holms_continue = any(any_significant);
    else
        holms_continue = false;
    end
end
% [stat.effect] = deal(effect_name{:});
if opt.holms
    varargout{1} = h_stat;
    varargout{2} = stat;
else
    varargout{1} = stat;
end