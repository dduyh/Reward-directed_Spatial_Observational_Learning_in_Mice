%%
clear; close all; clc;

%% set the path for data.

Directory = 'E:\ETH_Zurich\Master_Thesis\CBM_data\session3\';    % Main directory\
date = 'day11_Mar_31_2023';
mouse_name = 'mouse_LL';
type = 'obs';

%% set the coordinates for maze

load([Directory date '\' 'background.mat'], 'background')
figure(1);
imshow(background);
maze_coordinates = ginput(8);

%% calculate distance

trials = 15;

distance = NaN(1,trials);
reward_interval = NaN(1,trials);
trial_duration = NaN(1,trials);

pixel_size = 450;  % pixels/m

for trial_num = 1:trials
% for trial_num = [1:5 7:trials]

    trial = ['trial' num2str(trial_num)];

    Data_Folder = [Directory date '\' mouse_name '_' type '\' trial '\'];

    load([Data_Folder 'centers.mat']);   % Load the mouse coordinates data.

    centers(all(centers==0,2),:) = [];
    in = inpolygon(centers(:,1),centers(:,2),maze_coordinates(:,1),maze_coordinates(:,2));
    centers(~in,:) = [];

    locomotion = zeros(1,numel(centers)-1);

    for i = 1 : size(centers,1)-1
        mouse_dist = [centers(i,1), centers(i,2); centers(i+1,1), centers(i+1,2)];
        locomotion(i) = pdist(mouse_dist, 'euclidean');
    end

    distance(trial_num) = sum(locomotion)./pixel_size;

    load([Data_Folder 'step_timepoint.mat']);   % Load the mouse step timepoints.

    reward_interval(trial_num) = step_timepoint(4) - step_timepoint(2);
    trial_duration(trial_num) = step_timepoint(5) - step_timepoint(2);

end

%%
save([Directory date '\' mouse_name '_' type '\distance.mat'],'distance');
save([Directory date '\' mouse_name '_' type '\reward_interval.mat'],'reward_interval');
save([Directory date '\' mouse_name '_' type '\trial_duration.mat'],'trial_duration');
