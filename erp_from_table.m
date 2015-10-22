function erp = erp_from_table(trials, eeg, avgfun, byrow, ...
	within, across)

if ~exist('byrow', 'var')
	byrow = 'subject';
end

across_grp = get_grouping(trials, byrow);
agrp = unique(across_grp);
erp = zeros(length(agrp), size(eeg, 2));

for a = 1:length(agrp)
	current_a = agrp(a);
	current_rows = find(across_grp == current_a);
	within_grp = get_grouping(trials(current_rows, :), within);
	wgrp = unique(within_grp);
	for w = 1:length(wgrp)
		current_w = wgrp(w);
		rows = current_rows(within_grp == current_w);
		erp(a, :, w) = avgfun(eeg(rows, :, :));
	end
end

one_grp = group(across_grp);
merge = get_grouping(trials(one_grp(:,2), :), across);
umrg = unique(merge);
real_erp = zeros(length(umrg), size(erp, 2), size(erp, 3));
for m = 1:length(umrg)
    real_erp(m, :, :) = mean(erp(merge == umrg(m), :, :), 1);
end
erp = real_erp;


function grp = get_grouping(table, howgroup)

if isa(howgroup, 'function_handle')
	grp = howgroup(table);
else
	units = table.(howgroup);
	unique_units = unique(units);

	grp = zeros(size(units));
	for u = 1:length(unique_units)
		grp(units == unique_units(u)) = u;
	end
end
