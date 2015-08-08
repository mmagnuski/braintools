function out = setfun(pth, fun, varargin)

% loads .set files from given path one by one
% applies function fun to them
%
% examples
% --------
% chan_mean = @(EEG) mean(EEG.data, 2);
% all_chan_means = setfun('C:\DATA\EEG', chan_mean);


% defaults
overwrite = false;
out = {};

% check opts:
if any(strcmp('overwrite', varargin))
	overwrite = true;
end

% get file list
fls = dir(fullfile(pth, '*.set'));
fls = {fls.name};

for f = 1:length(fls)
	% load set
	ld = load(fullfile(pth, fls{f}), '-mat');
	EEG = ld.EEG;
	clear ld

	% apply fun
	if overwrite
		EEG = feval(fun, EEG);
	else
		out{f} = feval(fun, EEG);
	end

	% overwrite
	if overwrite
		save(fullfile(pth, fls{f}), 'EEG');
	end
end