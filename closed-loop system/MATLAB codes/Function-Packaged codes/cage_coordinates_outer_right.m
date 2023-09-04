% set the area coordinates of outer boundary for right cage
function [coordinates_out_right,bw_out_right] = cage_coordinates_outer_right(background)

figure(1);
disp('Please draw the outer boundary for right cage, and double click to save the coordinates    ');
bw_out_right=roipoly(background);
[r_out_right,c_out_right]=find(bw_out_right==1);

right_out_x1 = min(c_out_right);
right_out_y1 = min(r_out_right(c_out_right == min(c_out_right)));

right_out_x2 = min(c_out_right(r_out_right == min(r_out_right)));
right_out_y2 = min(r_out_right);

right_out_x3 = max(c_out_right);
right_out_y3 = max(r_out_right(c_out_right == max(c_out_right)));

right_out_x4 = max(c_out_right(r_out_right == max(r_out_right)));
right_out_y4 = max(r_out_right);

coordinates_out_right = [right_out_x1 right_out_x2 right_out_x3 right_out_x4; ...
    right_out_y1 right_out_y2 right_out_y3 right_out_y4];
