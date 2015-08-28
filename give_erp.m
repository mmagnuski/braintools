function erp = give_erp(EEG, chans, epoki, varargin)

% GIVE_ERP computes Event Related Potentials
% for chosen channels and epochs
%
% example:
% erp = give_erp(EEG, {'E23', 'E45'}, 'face');
% erp = give_erp(EEG, [1, 2, 5], 'car', 'ica');

iscomp = any(strcmp('ica', varargin));

% jeżeli pewne zmienne nie istnieją - 
% ustawiamy wartości domyślne
if ~exist('chans', 'var') || isempty(chans) || ...
	(ischar(chans) && strcmp(chans, 'all'))
    chans = 1:EEG.nbchan;
end
if ~exist('epoki', 'var') || isempty(epoki)
    epoki = 1:EEG.trials;
end
if ischar(epoki)
    epoki = {epoki};
end

% jeżeli kanały podane zostały po nazwach 
if ischar(chans)
	chans = {chans};
end
if iscell(chans)
	chans = find_elec(EEG, chans);
end

% jeżeli podano epoki jako nazwę warunku
if ischar(epoki) || iscell(epoki)
	[temp, epoki] = find(epoch_centering_events(EEG, epoki));
end

% alarm if no such epochs
if isempty(epoki)
    error('No epochs found matching requested condition.');
end

if ~iscomp
	erp = mean(EEG.data(chans, :, epoki), 3);
else
	ica_data = get_ica_data(EEG, chans);
	erp = mean(ica_data(:, :, epoki), 3);
end

% baseline
zero_ind = find_range(EEG.times, 0);
bsln_ind = 1:zero_ind;
bsln = mean(erp(:, bsln_ind), 2);
erp = bsxfun(@minus, erp, bsln);