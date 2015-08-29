classdef EpochDict < handle
    
    properties
        names
        name2epoch
        which_centering
    end
    
    methods
        function self = EpochDict(EEG)
            [cent, whichcent, names] = epoch_centering_events(...
                EEG);
            self.names = names;
            self.name2epoch = cent;
            self.which_centering = whichcent;
        end
        
        function event_ind = subsref(self, s)
            if strcmp(s(1).type, '()')
                test_names = s(1).subs;
                
                event_ind = [];
                for n = test_names
                    which_name = find(strcmpi(n{1}, self.names));
                    if ~isempty(which_name)
                        event_ind = unique([event_ind, find(...
                            self.name2epoch(which_name, :))]);
                    end
                end
            end
        end
    end
    
end