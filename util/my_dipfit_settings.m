function EEG = my_dipfit_settings(EEG)

% NOHELPINFO

% get path to eeglab
eegpth = fileparts(which('eeglab'));

% check dipfit version
bgpth = [eegpth, '\plugins\'];
lst   = dir(bgpth);
lst   = lst([lst.isdir]);
where = regexpWhere({lst.name}, 'dipfit');
dipver = lst(where).name(7:end);

% add path
addpath([eegpth, '\plugins\dipfit', dipver, '\']);

% transform vector
transf = [0.092784, -13.3654, -1.9004, 0.10575, 0.003062,...
    -1.5708, 10.0078, 10.0077, 10.1331];
hdmf = [eegpth, '\plugins\dipfit', dipver, '\',...
    'standard_BEM\standard_vol.mat'];
mrif = [eegpth, '\plugins\dipfit', dipver, '\',...
    'standard_BEM\standard_mri.mat'];
chanf = [eegpth, '\plugins\dipfit', dipver, '\',...
    'standard_BEM\elec\standard_1005.elc'];

% check channels
allchn = 1:length(EEG.chanlocs);

% % remove E62 and E63
% remind = zeros(1, length(remel));
% elstep = 0;
% for el = 1:length(remel)
%     elind = strcmp(remel{el}, {EEG.chanlocs.labels});
    
%     if sum(elind) == 1
%         elstep = elstep + 1;
%         remind(elstep) = find(elind);
%     end
% end

% % trim if some were not found:
% remind = remind(1:elstep);
% clear elstep el elind

% % remove these channels and badchannels:
% allchn(union(ICAw(r).chan.bad, remind)) = [];
goodchan = allchn;
clear allchn % remind

%% DIPfit
% dipfit options
EEG = pop_dipfit_settings( EEG, 'hdmfile', hdmf, 'coordformat', 'MNI',...
    'mrifile', mrif, 'chanfile', chanf, 'coord_transform', transf,...
    'chansel', goodchan);