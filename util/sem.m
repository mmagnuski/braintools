function hilow = sem(x)

% returns mean +/- 1.96*SEM
%
% hilow = sem(x)
%
% x - matrix where observations are in rows and
%     variables/timepoints (etc.) are in columns 
%
% SEM is simply:
% s/sqrt(n)
% s - sample standard deviation (unbiased)
% n - number of observations
% 
% a smarter way would be to use student t distribution
% but this simple approach seems to be most popular

s = std(x, 0, 1);
n = size(x, 1);
sem_val = s / sqrt(n);
m = mean(x, 1);
err = 1.96 * sem_val;

hilow = [m + err; ...
         m - err];