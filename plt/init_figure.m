function h = init_figure(effect)

effect_name = [effect, ' effect'];

% get screen centre
ss = get(0, 'ScreenSize');
ss = ss(3:4);
scent = mean([[1, 1]; ss], 1);

% FIGURE STRUCTURE
% ----------------

% figure size
figsz = [250, 265];
figsz = [round(scent - figsz), figsz * 2];

h.fig = figure('units', 'pixels',...
			  'position', figsz, ...
			  'color', [1,1,1],...
              'menubar', 'none');

% invisible backaxis
h.backax = axes('units', 'normalized', ...
			  'position', [0, 0, 1, 1], ...
			  'visible', 'off');

% create title
h.title = text(0.5, 0.98, effect_name, ...
			 'units', 'normalized', ...
			 'fontsize', 16, ...
			 'HorizontalAlignment', 'center');

% main axis
h.elec_ax = axes('units', 'normalized', ...
			  'position', [0.2, 0.65, 0.73, 0.27]);

