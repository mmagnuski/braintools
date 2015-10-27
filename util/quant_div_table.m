function grp = quant_div_table(table, sbj, byrow, q)

sbj = group(table.(sbj));

all_val = table.(byrow);
sbj_val = all_val(sbj(:,2));
qnt = quantile(sbj_val, q);

tgrp = zeros(size(sbj_val));
grp = zeros(size(all_val));
for q = 1:length(qnt)-1
	tgrp(sbj_val >= qnt(q) & sbj_val < qnt(q+1)) = q+1;
end
tgrp(sbj_val < qnt(1)) = 1;
tgrp(sbj_val >= qnt(end)) = length(qnt)+1;
for s = 1:size(sbj, 1)
	grp(sbj(s,2):sbj(s,3)) = tgrp(s);
end



