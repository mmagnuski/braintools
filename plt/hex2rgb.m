function rgb = hex2rgb(h)

h = {h(1:2), h(3:4), h(5:6)};
rgb = cellfun(@hex2dec, h);
rgb = rgb / 255;