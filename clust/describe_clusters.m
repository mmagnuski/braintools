function describe_clusters(stat, varargin)

ifneg = femp(stat, 'negclusters');
ifpos = femp(stat, 'posclusters');
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

if ifpos
	posnum = length(stat.posclusters);
	posclst = stat.posclusters(1);
	sigpos = sum([stat.posclusters.prob] < 0.05);
else
	posnum = 0;
	sigpos = 0;
end
if ifneg
	negnum = length(stat.negclusters);
	negclst = stat.negclusters(1);
	signeg = sum([stat.negclusters.prob] < 0.05);
else
	negnum = 0;
	signeg = 0;
end

prnt('Number of clusters\n', {});
prnt('------------------\n', {});
prnt('all positive clusters: %d\n', {posnum});
prnt('significant positive clusters: %d\n', {sigpos});
prnt('all negative clusters: %d\n', {negnum});
prnt('significant negative clusters: %d\n', {signeg});

if ifpos
prnt('\nmost significant positive cluster:\n', {});
prnt('p value: %4.3f\n', {posclst.prob});
prnt('summary stat: %5.2f\n', {posclst.clusterstat});
end

if ifneg
prnt('\nmost significant negative cluster:\n', {});
prnt('p value: %4.3f\n', {negclst.prob});
prnt('summary stat: %5.2f\n', {negclst.clusterstat});
end

if ifclose
	fclose(fid);
end