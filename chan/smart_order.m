function orderer = smart_order(EEG, varargin)


opt.remove_chin = false;
opt.remove_Cz = false;
if nargin > 0
    opt = parse_arse(varargin, opt);
end

% corr order does not make much sense
orderer.order = [...
    fliplr([8, 10, 11, 6, 9, 12, 13, 14, 19, 18, 64, 17, 63]), ...
    [5, 2, 3, 60, 59, 57, 56, 58, 61, 1, 62],...
    fliplr([fliplr([54, 53, 51, 50, 41, 34, 46, 49, 48, 52, 55]),...
    65, [4, 7, 15, 16, 21, 20, 22, 26, 25, 24, 23]]),...
    fliplr([36, 37, 35, 33, 31, 28, 27, 30, 32, 29]),...
    39, 38, 40, 42, 45, 44, 43, 47,...
    ];

% add useful info
orderer.front_num = 24;
orderer.mid_num = 23;
orderer.back_num = 18;

labels = find_elec(EEG, []);

if opt.remove_Cz || length(labels) < 65
    orderer.order(orderer.order == 65) = [];
    orderer.mid_num = orderer.mid_num - 1;
end
% removing chin elecs if needed
if opt.remove_chin
	% remove chin elecs: 63, 62
	orderer.order(orderer.order == 62 | orderer.order == 63) = [];
	% change index of the last remaining
	orderer.order(orderer.order >= 64) = ...
        orderer.order(orderer.order >= 64) - 2;

	% adjust front num
	orderer.front_num = orderer.front_num - 2;
end

% calculate limits
cumul = cumsum([orderer.front_num, orderer.mid_num, orderer.back_num]);
orderer.front_lim  =  [1,            cumul(1)];
orderer.mid_lim    =  [cumul(1) + 1, cumul(2)];
orderer.back_lim   =  [cumul(2) + 1, cumul(3)];

