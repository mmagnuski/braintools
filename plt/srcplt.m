function srcplt(src, mri)

if exist('mri', 'var')
% interpolate test
cfg = [];
cfg.downsample = 2;
cfg.parameter = 'pow';
src = ft_sourceinterpolate(cfg, src, mri);
end

% plot interpolated test values:
cfg = [];
cfg.method = 'slice';
cfg.funparameter = 'pow';
ft_sourceplot(cfg, src);