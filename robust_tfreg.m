function [t, p] = robust_tfreg(data, beh, varargin)

% returns t and p values of robust regression
% against each pixel in data map (2D)
% the assumed modelled relation is EEGdata --> behavior
% or EEGdata + cobehavioraldata --> someotherbehavior
% to explain EEGdata by multiple experimental variables
% use 'dir', '-->brain'
% in this case the output's last dimension corresponds
% to predictors input to the model (plus intercept as
% the first one)
%
% usage:
% ------
% [t, p] = robust_tfreg(data, beh, varargin)
% data - trials x dim1 x dim2 matrix
% beh  - trials x vars matrix of behavioral measures
% optional input:
% 'dir', '-->brain' - informs that the regression should
%                     be performed with data as dependent
%                     variable
% 'step' - used for progress bar
% 'verbose' - used for progress bar too?
% 'logtransform' - whether to log-transform the data

%
% by Miko, 2014, february

% CONSIDER
% cluster correction may be useful later


% settings:
step = 100;
verbose = true; %#ok<*NASGU>
cobeh = [];
cobrain = [];
dir = 'brain-->';
logtransform = false;

% flip beh if needed:
if size(beh, 1) == 1
    beh = beh';
end

% check varargin
if ~isempty(varargin)
    keycheck = {'step', 'verbose', 'cobeh', 'cobrain', 'dir',...
        'logtransform'};
    for k = 1:length(keycheck)
        test = strcmp(keycheck{k}, varargin);
        if sum(test) > 0
            eval([keycheck{k}, ' = varargin{',...
                num2str(find(test) + 1), '};']);
        end
    end
    clear k test keycheck varargin
end

if ~isempty(cobrain)
    size_check = size(cobrain) == size(data);
end

% checking dir
% dir is reformatted to 1 or 2 here:
if isequal(dir, '-->brain')
    % we are explaining brain signal, so:
    dir = 2;
else
    dir = 1;
end

% additional behavioral variables
% in the case of brain-->
if ~isempty(cobeh)
    if size(cobeh, 1) == 1
        cobeh = cobeh';
    end
    % number of additional variables:
    num_cobeh_vars = size(cobeh,2);
end

% assuming data are rpt_(dim1 by dim2)
sz = size(data);
if length(sz) > 2
    sz = sz(2:3); % dim1 by dim2
else
    sz = [sz(2), 1];
end

numsteps = prod(sz);
thisstep = 0;

if dir == 1
[t, p] = deal(zeros(sz));
else
    [t, p] = deal(zeros(size(beh, 2) + 1, sz(1), sz(2)));
end
strlen = 0;

% turn off the iteration limit warning:
warning('off', 'stats:statrobustfit:IterationLimit');

for i = 1:sz(1)
    for j = 1:sz(2)
        
        if verbose
            % ============
            % update view:
            thisstep = thisstep + 1;
            if mod(thisstep, step) == 0
                fprintf(repmat('\b', [1, strlen]));
                str = sprintf('Step %d / %d', thisstep, numsteps);
                strlen = length(str);
                fprintf(str);
            end
        end
        
        % ===================
        % compute robust regr
        try % <-- hm, hm, not a very good solution to NaNs...
            
            % CHANGE:
            % log tranform should be at the beginning
            if logtransform
                dt = log(data(:,i,j)); %#ok<UNRCH>
            else
                dt = data(:,i,j);
            end
            
            if dir == 1
                % brain -->
            if isempty(cobeh)
                [~, stats] = robustfit(dt, beh);
                t(i,j) = stats.t(2); % first t is for constant
                p(i,j) = stats.p(2); % first p is for constant
            else
                [~, stats] = robustfit([cobeh, squeeze(dt)], beh);
                t(i,j) = stats.t(num_cobeh_vars + 2);
                p(i,j) = stats.p(num_cobeh_vars + 2);
            end
            
            else
               % --> brain option
               [~, stats] = robustfit(beh, squeeze(dt));
               t(:,i,j) = stats.t;
               p(:,i,j) = stats.p;
            end
        catch ThisError
            % you can check error here...
            t(i,j) = NaN;
            p(i,j) = NaN;
        end
    end
end

% turn the warning back on:
warning('on', 'stats:statrobustfit:IterationLimit');

if verbose
    fprintf('\n');
end

% goodbye!