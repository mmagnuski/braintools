function describe_clusters(clst, varargin)

% describe clusters obtained with get_clusters

% notes
% ifclose is used to track whether file needs to be closed

% probfld = {'prob', 'p'};
% if ifpos
%     goodf = isfield(stat.posclusters, probfld);
% end
% probfld = probfld(goodf);
% probfld = probfld{1};

% stat field
% statfld = {'clusterstat', 'val'};
% if ifpos
%     goodf = isfield(stat.posclusters, statfld);
% end
% statfld = statfld(goodf);
% statfld = statfld{1};

ifclose = false;
if nargin > 1
	% output file:
	if ischar(varargin{1})
		fileout = varargin{1};
		fid = fopen(fileout, 'w');
		ifclose = true;
	elseif isnumeric(varargin{1})
		fid = varargin{1};
	end
	prnt = @(str, rst) fprintf(fid, str, rst{:});
else
	prnt = @(str, rst) fprintf(str, rst{:});
end

which_pos = strcmp('pos', {clst.pol});
posnum = sum(which_pos);
negnum = length(clst) - posnum;

prnt('Number of clusters\n', {});
prnt('------------------\n', {});
% prnt('all positive clusters: %d\n', {posnum});
prnt('significant positive clusters: %d\n', {posnum});
% prnt('all negative clusters: %d\n', {negnum});
prnt('significant negative clusters: %d\n', {negnum});

for c = 1:length(clst)
    te = clst(c).timedges;
    prnt('\n--Cluster %d--\n', {c});
    prnt('polarity: %s\n', {clst(c).pol});
    prnt('p value: %4.3f\n', {clst(c).prob});
    prnt('time range: %4.3f - %4.3f s\n', {te(1), te(2)});
end


if ifclose
	fclose(fid);
end