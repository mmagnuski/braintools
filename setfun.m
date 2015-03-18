function setfun(pth, fun, varargin)

% loads .set files from given path one by one
% applies function fun to them and overwrites


% defaults
overwrite = false;

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
		feval(fun, EEG);
	end

	% overwrite
	if overwrite
		save(fullfile(pth, fls{f}), 'EEG');
	end
end