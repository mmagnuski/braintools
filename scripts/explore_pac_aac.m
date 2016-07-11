% get an EEG
braintools
eeg_path('add');
dropbox_pth = 'C:\Users\Ola\Dropbox';
data_pth = fullfile(dropbox_pth, 'Sarenka\PAC\dane\OSCLM 02\RAVEN\cln SET');
fls = dir(fullfile(data_pth, '*.set'));

EEG = pop_loadset(fullfile(data_pth, fls(1).name));

% reformat
aac = squeeze(AAC_t(2, :, :, :));
aac = permute(aac, [2, 3, 1]);
explore_data(EEG, aac, 'captype', 'biosemi64')

% for comparison, intercept:
aac = squeeze(AAC_t(1, :, :, :));
aac = permute(aac, [2, 3, 1]);
explore_data(EEG, aac, 'captype', 'biosemi64')

pac = squeeze(PAC_t(2, :, :, :));
pac = permute(pac, [2, 3, 1]);
explore_data(EEG, pac, 'captype', 'biosemi64')

pac = squeeze(PAC_t(1, :, :, :));
pac = permute(pac, [2, 3, 1]);
explore_data(EEG, pac, 'captype', 'biosemi64')