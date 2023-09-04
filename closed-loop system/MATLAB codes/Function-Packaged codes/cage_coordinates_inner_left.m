% set the area coordinates of inner boundary for left cage
function [coordinates_in_left,bw_in_left] = cage_coordinates_inner_left(background)

figure(1);
disp('Please draw the inner boundary for left cage, and double click to save the coordinates    ');
bw_in_left=roipoly(background);
[r_in_left,c_in_left]=find(bw_in_left==1);

left_in_x1 = min(c_in_left);
left_in_y1 = min(r_in_left(c_in_left == min(c_in_left)));

left_in_x2 = min(c_in_left(r_in_left == min(r_in_left)));
left_in_y2 = min(r_in_left);

left_in_x3 = max(c_in_left);
left_in_y3 = max(r_in_left(c_in_left == max(c_in_left)));

left_in_x4 = max(c_in_left(r_in_left == max(r_in_left)));
left_in_y4 = max(r_in_left);

coordinates_in_left = [left_in_x1 left_in_x2 left_in_x3 left_in_x4; ...
    left_in_y1 left_in_y2 left_in_y3 left_in_y4];
