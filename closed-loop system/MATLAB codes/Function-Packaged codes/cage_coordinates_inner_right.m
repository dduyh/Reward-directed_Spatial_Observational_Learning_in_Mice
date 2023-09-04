% set the area coordinates of inner boundary for right cage
function [coordinates_in_right,bw_in_right] = cage_coordinates_inner_right(background)

figure(1);
disp('Please draw the inner boundary for right cage, and double click to save the coordinates    ');
bw_in_right=roipoly(background);
[r_in_right,c_in_right]=find(bw_in_right==1);

right_in_x1 = min(c_in_right);
right_in_y1 = min(r_in_right(c_in_right == min(c_in_right)));

right_in_x2 = min(c_in_right(r_in_right == min(r_in_right)));
right_in_y2 = min(r_in_right);

right_in_x3 = max(c_in_right);
right_in_y3 = max(r_in_right(c_in_right == max(c_in_right)));

right_in_x4 = max(c_in_right(r_in_right == max(r_in_right)));
right_in_y4 = max(r_in_right);

coordinates_in_right = [right_in_x1 right_in_x2 right_in_x3 right_in_x4; ...
    right_in_y1 right_in_y2 right_in_y3 right_in_y4];
