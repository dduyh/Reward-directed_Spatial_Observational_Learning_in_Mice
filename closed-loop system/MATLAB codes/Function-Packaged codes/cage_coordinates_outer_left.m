% set the area coordinates of outer boundary for left cage
function [coordinates_out_left,bw_out_left] = cage_coordinates_outer_left(background)

figure(1);
disp('Please draw the outer boundary for left cage, and double click to save the coordinates    ');
bw_out_left=roipoly(background);
[r_out_left,c_out_left]=find(bw_out_left==1);

left_out_x1 = min(c_out_left);
left_out_y1 = min(r_out_left(c_out_left == min(c_out_left)));

left_out_x2 = min(c_out_left(r_out_left == min(r_out_left)));
left_out_y2 = min(r_out_left);

left_out_x3 = max(c_out_left);
left_out_y3 = max(r_out_left(c_out_left == max(c_out_left)));

left_out_x4 = max(c_out_left(r_out_left == max(r_out_left)));
left_out_y4 = max(r_out_left);

coordinates_out_left = [left_out_x1 left_out_x2 left_out_x3 left_out_x4; ...
    left_out_y1 left_out_y2 left_out_y3 left_out_y4];
