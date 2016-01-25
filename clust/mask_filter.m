function mask = mask_filter(mask, prop)

kern = [1,1,1;1,0,1;1,1,1];
temp = zeros(size(mask));
for m = 1:size(mask, 3)
    temp(:,:,m) = conv2(mask(:,:,m), kern, 'valid');
end

mask = temp > prop;