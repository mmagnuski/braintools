function EEG = reref_to_avg(EEG, varargin)

opt.keepref = true;
if nargin > 1
    opt = parse_arse(varargin, opt);
end

if opt.keepref
    ref = EEG.chanlocs(1).ref;
    which_ref = strcmp(ref, {EEG.chaninfo.nodatchans.labels});
    if any(which_ref)
        which_ref = find(which_ref);
        ref_struct = EEG.chaninfo.nodatchans(which_ref(1));
        
        EEG = pop_reref(EEG, [], 'keepref', 'on', 'refloc', ref_struct);
    else
        error('Could not find original reference.');
    end
else
    EEG = pop_reref(EEG, []);
end