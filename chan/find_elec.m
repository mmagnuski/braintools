function electrodes_id = find_elec(EEG, electrodes)

% finds electrode indices from electrode labels
% works both for EEGlab and FieldTrip formats
% electrodes_id = eeg_findelec(EEG, electrodes)
% where electrodes is a string or cell of strings
%
% FIXHELPINFO

% ADD tolerance to absent electrodes

% test if numerical
if isempty(electrodes)
    electrodes = true;
elseif isnumeric(electrodes)
    error(['The electrodes are already',...
        ' numeric as if representing electrode indices']);
else
    
    % test if elec are char:
    if ischar(electrodes)
        electrodes = {electrodes};
    end
    
    len = length(electrodes);
    % test if elec are in cell
    if iscell(electrodes) && ...
            sum(cellfun(@ischar, electrodes)) == len
        
        num = false;
    else
        error('Electrodes are neither numeric, character nor cell :(')
    end
end

% both EEGlab and FieldTrip structures
% are allowable, as well as cell array of strings
if isstruct(EEG)
if femp(EEG, 'chanlocs')
    lb = {EEG.chanlocs.labels};
elseif femp(EEG, 'label')
    lb = EEG.label;
end
elseif iscell(EEG)
    lb = EEG;
else
    error('Unrecognized first input.')
end

if islogical(electrodes)
    electrodes_id = lb;
    return
end

if ~num
    electrodes_id = cellfun(@(x) find(strcmp(x, lb)), electrodes);
end