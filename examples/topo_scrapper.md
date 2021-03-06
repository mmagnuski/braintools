## using `topo_scrapper`
To have flexible control over your topoplot (eeglab function) figure it is useful to get handles to topoplot elements. `topo_scrapper` dives into your topoplot and returns you handles to its elements.
#### *Example 1: setting electrodes color*
Let's say that you have a vector `elec_pval` that contains p-values for effects on consecutive electrodes. You want to draw electrodes with p value between 0.05 and 0.01 with gray and electodes with p value below 0.01 with white. I am assuming you are using 64 channel EGI cap.
First, lets set things up:
```matlab
% construct scalp effect
val = [ ...
    1.1161, -0.91364, -1.838, -3.2016, 0.066259, -1.4606, ...
    -3.3993, -0.97375, -2.0922, -0.6178, -1.4311, -2.2535, ...
    -1.4974, -2.2135, -2.4081, -3.2293, 0.4702, -0.012729, ...
    -0.96738, -2.7746, -2.414, -2.1335, 0.37547, 0.40911, ...
    -0.80614, -0.99055, -0.24086, -1.1567, 1.9843, 1.573, ...
    0.049714, 1.9055, 0.2824, -0.84669, 1.7897, 1.4259, ...
    2.4099, 1.3051, 2.3575, 1.679, -1.1391, 1.5863, ...
    3.7668, 3.3526, 1.8125, 1.1898, 3.5081, 1.8751, ...
    0.10936, -1.2853, -2.2585, 2.8515, -2.3118, -2.9646, ...
    2.0567, 0.22197, -0.88577, 1.0393, -0.1355, -1.1135, ...
    2.2828, 0.8679, ...
];

% construct fake p-values (hooray!)
signif_elecs = [...
    2:4, 6:9, 11:16, 18:22, 25, 26, ...
    41, 50, 51, 53, 54, 57, 60, ...
];
signif_levels = logical(round(rand(length(signif_elecs), 1)));
elec_pval = ones(62, 1);
elec_pval(signif_elecs(signif_levels)) = 0.04;
elec_pval(signif_elecs(~signif_levels)) = 0.0023;

% create colors
wh = ones(1, 3);
gr = wh * 0.7;
```

Now, let's plot a topoplot:
```matlab
topoplot(val, EEG.chanlocs([1:61, 64])); % we are not using cheek electrodes
```
![alt tag](https://raw.githubusercontent.com/mmagnuski/braintools/master/docs/pics/Ex01_01.PNG)

Then we use topo_scrapper and see what it brings to the table:
```
>> topo = topo_scrapper(gca);
>> topo
topo = 
        elec_marks: 192
          left_ear: 190
         right_ear: 189
              nose: 188
              head: 187
          elec_pos: [62x3 double]
    one_elec_group: 1
             title: 191
             patch: 186
           hggroup: 175
```

What we see are predominantly handles to different parts of the topoplot.
We want to draw the electrodes our way, so we delete default electrode markers:
```matlab
delete(topo.elec_marks);
```
Now we plot our 0.05 - 0.01 electrodes in gray. 
We first create `elecs` vector that says which electrodes are within 0.05 - 0.01 pval range 
and then use `line` function to plot invisible line with visible markers (kind of confusing, 
I know, you can use `scatter` too). `topo_scrapper` gave us electrode positions in the 
graphical axis in the `elec_pos` field.
```matlab
elecs = elec_pval < 0.05 & elec_pval >= 0.01;
line(...
    topo.elec_pos(elecs, 1), ...
    topo.elec_pos(elecs, 2), ...
    topo.elec_pos(elecs, 3), ...
    'marker', '.', ...
    'linestyle', 'none', ...
    'markeredgecolor', gr, ...
    'markersize', 23 ...
);
```
Then we plot the electrodes with pval below 0.01 in white:
```matlab
elecs = elec_pval < 0.01;
line(...
    topo.elec_pos(elecs, 1), ...
    topo.elec_pos(elecs, 2), ...
    topo.elec_pos(elecs, 3), ...
    'marker', '.', ...
    'linestyle', 'none', ...
    'markeredgecolor', wh, ...
    'markersize', 23 ...
);
```
![alt tag](https://raw.githubusercontent.com/mmagnuski/braintools/master/docs/pics/Ex01_02.png)
