function [x_max y_max max] = maxlist(xy)
[val ind] = max(xy);
x_max = xy(ind(2),1);
y_max = xy(ind(2),2);
max = val(2);