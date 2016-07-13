% turn AAC (PAC?) contrasts to fieldtrip tfr representation

% get an EEG
braintools
eeg_path('add');
dropbox_pth = get_valid_path({'C:\Users\swps\Dropbox', ...
    'C:\Users\Ola\Dropbox'});
base_pac_pth = fullfile(dropbox_pth, 'Sarenka\PAC');
data_pth = fullfile(base_pac_pth, 'dane\OSCLM 02\RAVEN\cln SET');
fls = dir(fullfile(data_pth, '*.set'));

EEG = pop_loadset(fullfile(data_pth, fls(1).name));
eeg = eeg2ftrip(EEG);

% dims
lf = 3.5:0.5:8.5;
hf = 15:5:60;


%%
eeg = eeg2ftrip(EEG);
ch_names = {'Fp1', 'Fp2', 'AF3', 'AF4', 'F3', 'Fz', 'F4', 'FC2', ...
'FC1', 'C3', 'Cz', 'C4', 'CP2', 'CP1', 'P4', 'Pz', 'P3', ...
'PO3', 'PO4', 'O2', 'Oz', 'O1'};

n_ch = length(ch_names);
which_labels = cellfun(@(x) find(strcmp(eeg.label, x)), ch_names);

% change num of channels (also in trials)
eeg.label = eeg.label(which_labels);
eeg.elec.label = eeg.label;
eeg.elec.pnt = eeg.elec.pnt(which_labels, :);
for t = 1:length(eeg.trial)
    eeg.trial{t} = eeg.trial{t}(1:n_ch, :);
end



%% diag effects
dt = load('C:\Users\swps\Dropbox\Sarenka\PAC\analiza\OSCLM 02\mixit\intelligences.mat');
sbj = {'AD1504', 'MM1010', 'MS0708', 'PZ0301', 'JR2401', 'MW0312', ...
    'KG2310', 'MP1412', 'BM1212', 'AM1805', 'KS1112', 'JK1110', ...
    'KM3007', 'PP1512', 'SW0909', 'DM0809', 'IZ2409', 'ST1204', ...
    'DJ0909', 'DP0606', 'MM2501', 'KS0610', 'BF2811', 'FW1312', ...
    'KD0106', 'AI1212', 'MZ0508', 'MD1611', 'NZ2303', 'WD1801', ...
    'DT3012', 'PC1702', 'WG0501', 'AZ1911', 'LM1602', 'US2101', ...
    'AW2110', 'AK0201', 'RR0309', 'JP0506', 'ST0407', 'FW0302', ...
    'WW0102'};

% get iq
iq = zeros(length(sbj), 1);
for s = 1:length(sbj)
    iq(s) = dt.(sbj{s})(2);
end

dt = load('C:\Users\swps\Dropbox\Sarenka\PAC\analiza\OSCLM 02\mixit\for_cluster_cor.mat');
subj_data = cell(length(sbj), 1);

for s = 1:length(sbj)
    subj_data{s} = to_ft_tfr(eeg, dt.(sbj{s}));
end

% cluster cfg
cfg = get_cluster_cfg();
cfg.statistic = 'indepsamplesregrT';
cfg.neighbours = ngb;
cfg.design = iq';
cfg.statistic = 'correlationT';
% cfg.type = 'Pear';
cfg.clusteralpha = 0.1;

stat = ft_freqstatistics(cfg, subj_data{:});

% check if significant
clst = get_cluster(stat);

% see stat
st = permute(stat.stat, [2, 3, 1]);
explore_data(EEG, st, 'captype', 'biosemi64', ...
    'xaxis', lf, 'yaxis', hf);


% %% check correlations
% dt = load('C:\Users\swps\Dropbox\Sarenka\PAC\analiza\OSCLM 02\mixit\for_cluster_cor.mat');
% corr_data = zeros(length(sbj), 22, 25);
% 
% for s = 1:length(sbj)
%     corr_data(s, :, :) = dt.(sbj{s});
% end
% 
% corriq = reshape(corriq, [43, 22 * 25]);
% corr_data = reshape(corr_data, [43, 22 * 25]);
% [r, p] = corr(corriq, corr_data);
