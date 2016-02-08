classdef project < handle
    
    % TODOs:
    % [ ] - pull out valid_path from ICAw_path
    % [ ] - use valid_path in returning path
    % [ ] - implement indexing so that proj('fig')
    %       works ok
    %
    
    properties (SetAccess = private, GetAccess = public)
        protected % protected variables
        paths     % paths to use (fields like 'code', 'figures')
    end
    
    methods
        
        function obj = project()
            obj.protected = {};
            obj.paths = struct('code', [], 'figures', [], ...
                'data', [], 'db', []);
        end
        
        function protect(obj, varnames)
            % add variable(s) to those protected by the project
            if iscell(varnames)
                obj.protected = [obj.protected, varnames];
            else
                obj.protected{end+1} = varnames;
            end
        end
        
        function cl(obj)
            % clears base variables not protected by the project
            except_vars = strsep(obj.protected, ' ');
            com = ['clearvars -except ', except_vars];
            evalin('base', com);
        end

        function addp(obj, label)
            if isfield(obj.paths, label)
                addpath(get_valid_path(obj.paths.(label)));
            end
        end

        function pth = pth(obj, label, pth, onpthlabel)
            ifpth = exist('pth', 'var');
            ifonpth = exist('onpthlabel', 'var');
            
            if ifpth
                if ifonpth
                    pth = fullfile(obj.pth(onpthlabel), pth);
                end
                % check if label exists:
                if ~iscell(pth)
                    pth = {pth};
                end

                if isfield(obj.paths, label)
                    obj.paths.(label) = [obj.paths.(label), ...
                        pth];
                else
                    obj.paths.(label) = pth;
                end
            else
                if isfield(obj.paths, label)
                    pth = get_valid_path(obj.paths.(label));
                end
            end
        end

        function files = fls(obj, pthlabel, ext, expr)
            hasext = exist('ext', 'var') && ~isempty(ext);
            hasexp = exist('expr', 'var');

            files = dir(obj.pth(pthlabel));
            files = files(~[files.isdir]);
            files = {files.name};
            if hasext
                corr_ext = false(length(files), 1);
                for f = 1:length(files)
                    [~, ~, thisext] = fileparts(files{f});
                    corr_ext(f) = any(strcmp(thisext, ext)) ...
                        || any(strcmp(thisext(2:end), ext));
                end
                files = files(corr_ext);
            end
        end



        function cd(obj, label)
            if isfield(obj.paths, label)
                cd(get_valid_path(obj.paths.(label)));
            end
        end
        
        function op(obj, label)
            % open given folder in windows explorer
            % (currently works only in windows)
            if isfield(obj.paths, label)
                winopen(get_valid_path(obj.paths.(label)));
            end
        end
        
        function out = subsref(obj, s)
            methodnames = {'op', 'protect', 'cl', 'cd', ...
                'fls', 'pth', 'addp'};
            output = logical([0, 0, 0, 0, 1, 1, 0]);
            if length(s) == 1 && strcmp(s.type, '()')
                if isfield(obj.paths, s.subs{1})
                    out = get_valid_path(obj.paths.(s.subs{1}));
                end
            elseif strcmp(s(1).type, '.') && ~iscell(s(1).subs) && ...
                    any(strcmp(s(1).subs, methodnames))
                whichmethod = strcmp(s(1).subs, methodnames);
                if output(whichmethod)
                    out = eval([s(1).subs, '(obj, s(2).subs{:});']);
                else
                    eval([s(1).subs, '(obj, s(2).subs{:});']);
                end
            else
                out = builtin('subsref', obj, s);
            end
        end
    end
    
end