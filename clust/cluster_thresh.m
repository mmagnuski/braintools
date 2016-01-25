function clusters = cluster_thresh(data, chanconn, thresh, varargin)

% clusters = cluster_thresh(data, chanconn, thresh)
% clusters = cluster_thresh(data, chanconn, '5%')
%
% optional args:
% 'chandim' - which dimension of data is channels
% 'minchan' - minimum number of neighbouring channels

opt.chandim = 1;
opt.minchan = 0;
if nargin > 3
    opt = parse_arse(varargin, opt);
end


ifperc = strfind(thresh, '%');
if ifperc
    thresh(ifperc) = [];
    thresh = str2num(thresh)/100; %#ok<ST2NM>

    len = numel(data);
    smp = round(thresh * len);
    smp = max(1, smp);

    data_unrl = sort(data(:), 'descend');
    thresh = data_unrl(smp);
end

if opt.chandim ~= 1
    dims = 1:ndims(data);
    restdims = dims;
    restdims(opt.chandim) = [];
    dims = [dims(opt.chandim), restdims];

    data = permute(data, dims);
end

clusters = findcluster(data >= thresh, chanconn, opt.minchan);

if opt.chandim ~= 1
    [~, ord] = sort(dims);
    clusters = permute(clusters, ord);
end