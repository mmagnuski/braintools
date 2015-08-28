function newmat = renum_mat(mat, newnumord)

newmat = zeros(size(mat));
for o = 1:length(newnumord)
	newmat(mat == newnumord(o)) = o;
end