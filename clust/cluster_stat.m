classdef cluster_stat < handle
    
    % object for storing and interacting with results of cluster correction
    %
    % clst = cluster_stat(stat);
    % clst('pos', 'lab', 1) <- labels for first positive cluster
    % clst('pos', 'p', 1:10) <- p-values for first 10 positive clusters
    % clst('p') <- p-values for all clusters
    % clst('p', '<0.05') or clst('p', '*') <- all significant clusters
    % clst('pos', '*') <- positive significant clusters
    % clst('**') <- all significant at p < 0.01

    
    properties
        h
        t
        dims
        last_str
        opt
        EEG
    end

    properties (Acess = private)
        has
        lab
    end
    
    methods
        function cluster_stat(self, stat)
            % stat must be struct (cell of structs should give back
            % multiple cluster_stat objects or one with multiple effects?)
            if isstruct(stat)
                self.stat = stat;
            elseif iscell(stat)
                self.stat = stat{1};
            end
            % statfields
            statfields = fields(stat);

            % get labels
            prefix = {'pos', 'neg'};
            label_fields = {'labels', 'labelsmat', 'labelmat', ...
                'clusterslabelmat', 'clusterlabelmat', ...
                'clusterlabelsmat', 'clusterslabelsmat'};
            for pref = prefix
                self.has.(pref{1}) = false;
                for lab = label_fields
                    test = strcmp([pref{1}, lab{1}], statfields);
                    if any(test)
                        self.has.(pref{1}) = true;
                        self.lab.(pref{1}) = stat.([pref{1}, lab{1}]);
                        break
                    end
                end
            end
            self.has.both = self.has.pos && self.has.neg;

            % get cluster values
            value_fields = {'clusters', 'cluster'};
            for pref = prefix
                if ~self.has.(pref{1})
                    continue
                end
                for val = value_fields
                    test = strcmp([pref{1}, val{1}], statfields);
                    if any(test)
                        self.val.(pref{1}) = stat.([pref{1}, val{1}]);
                    end
                end
            end


            % get other stuff - channel labels, channel pos, time, frequency etc.
            self.opt.freq = get_fld(stat, {'freq', 'frequency', 'freqs'});
            self.opt.time = get_fld(stat, {'time', 'times'});
            self.opt.chanlab = get_fld(stat, {'labels', 'label', 'chanlabels'});
            self.opt.chanpos = get_fld(stat, {'positions', 'chanpos', ...
                'channel_positions'});
        end

        function val = subsref(self, ind)
            if strcmp(ind.type, '()')
                % ind.subs will be a cell matrix of indexers
            end
        end

    end
end
    