function [EEG1, EEG2] = reorder_channels(EEG1, EEG2)

chans1 = {EEG1.chanlocs.labels};
chans2 = {EEG2.chanlocs.labels};

chan2chan = cellfun(@(x) find(strcmp(...
	x, chans1)), chans2, 'Uni', false);

goodchan = ~cellfun(@isempty, chan2chan);
EEG2 = pick_channels(EEG2, find(goodchan));
chan2chan = cell2mat(chan2chan(goodchan));
EEG1 = pick_channels(EEG1, chan2chan);