function EEG = pick_channels(EEG, pick)

if iscell(pick)
    pick = find_elec(EEG, pick);
end
EEG.chanlocs = EEG.chanlocs(pick);
numch = length(EEG.chanlocs);
EEG.nbchan = numch;
if ismatrix(EEG.data)
    EEG.data = EEG.data(pick,:);
elseif ndims(EEG.data) == 3
    EEG.data = EEG.data(pick,:,:);
end
