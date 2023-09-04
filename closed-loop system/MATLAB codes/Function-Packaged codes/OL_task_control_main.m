%Spatial and Reward coding during Observational learning in mice

%Real-time image acquisition and mice tracking workflow:

%Left cage: Demo Mouse
%Right cage: Observer Mouse

%Change the saving file folders’ names;
%Check the serial port number of Arduino board;
%Start the video recording, take the first frame as background;
%Place the mice into cages;

%Author:  Yihui Du
%Date: 	January 5th, 2022

%%
clear; close all; clc;

%% select mode
disp('Mode 1: Drop one pellet every 30 secs for demo mouse.')
disp('Mode 2: Drop one pellet every 30 secs for observer mouse.')
disp('Mode 3: Manully provide 5 pellets for 3 trials on/in the maze for demo mouse.')
disp('Mode 4: Manully provide 5 pellets for 3 trials on/in the maze for observer mouse.')
disp('Mode 5: Demo mouse training.')
disp('Mode 6: Observer mouse training.')
disp('Mode 7: Observational learning multiple trials with tone.')
disp('Mode 8: Observer learning session.')
disp('Mode 9: Observer testing session.')

mode = input('Enter mode number: ');

%% set the path for output data.

mouse_num = 1;

Directory = 'D:\yihui\CBM_data\';    % Main directory\
date = 'day7_Nov_23_2022';

if mouse_num == 1       % mode 1 2 3 4 5 6 7

    mouse_name = 'mouse_LLR';
    type = 'demo';
    Folder = [Directory date '\' mouse_name '_' type '\'];

elseif mouse_num == 2   % mode 8 9

    mouse_name1 = 'mouse_LLR';
    type1 = 'demo';
    mouse_name2 = 'L';
    type2 = 'obs';
    Folder = [Directory date '\' mouse_name1 '_' type1 '_' mouse_name2 '_' type2 '\'];

end

%% Initialize the door and food dispenser controlled by arduino

s = arduino_initialization();

%% OPEN VIDEO INPUT (maze)

vid_maze = video_initialization_maze();   % mode 3 4 5 6 7 8 9

%% Get and save the background image

background = background_image(vid_maze,Folder);    % mode 3 4 5 6 7 8 9

%% OPEN VIDEO INPUT (cages)

vid_cage = video_initialization_cage();   % mode 1 2 5 6 7 8 9

%% set the area coordinates of inner boundary for left cage

[coordinates_in_left,bw_in_left] = cage_coordinates_inner_left(background);       % mode 3 5 7 8

%% set the area coordinates of outer boundary for left cage

[coordinates_out_left,bw_out_left] = cage_coordinates_outer_left(background);     % mode 3 5 8

%% set the area coordinates of inner boundary for right cage

[coordinates_in_right,bw_in_right] = cage_coordinates_inner_right(background);    % mode 4 6 9

%% set the area coordinates of outer boundary for right cage

[coordinates_out_right,bw_out_right] = cage_coordinates_outer_right(background);  % mode 4 6 9

%% Set the Tracking Parameters.

FrameRate = 15;

trial_length = 600; % 10 mins (600 secs)
exploration_threshold = 180; % 3 mins (180 secs)
initialization_threshold = 60; % 1 mins (60 secs)

thresh = 0.4;
cage_in_thresh = 20000;
cage_out_thresh = 36000;

%% set the center coordinates for rewards

% mode 5 6 7 8 9

figure(1);
imshow(background);
reward_center = ginput(1);

reward_on_maze = 1;  % true(1) / false(0)

reward_radius = 45;  % 10 cm * pixel_size

duration_range = 3;  % previous 3 secs

duration_threshold = 2; % 2 secs


%% Trial number

trial_num = '1';

switch mode
    case 1       % Drop one pellet every 30 secs for demo mouse.
        pellet_habituation_left(Folder,s,vid_cage,FrameRate,trial_num)

    case 2       % Drop one pellet every 30 secs for observer mouse.
        pellet_habituation_right(Folder,s,vid_cage,FrameRate,trial_num)

    case 3       % Manully provide 5 pellets for 3 trials on/in the maze for demo mouse.
        maze_cage_habituation_left(Folder,s,vid_maze,background,coordinates_in_left, ...
            bw_in_left,coordinates_out_left,bw_out_left,FrameRate,trial_length, ...
            exploration_threshold,cage_in_thresh,cage_out_thresh,trial_num)

    case 4       % Manully provide 5 pellets for 3 trials on/in the maze for observer mouse.
        maze_cage_habituation_right(Folder,s,vid_maze,background,coordinates_in_right, ...
            bw_in_right,coordinates_out_right,bw_out_right,FrameRate,trial_length, ...
            exploration_threshold,cage_in_thresh,cage_out_thresh,trial_num)

    case 5       % Demo mouse training.
        OL_demo_training(Folder,s,vid_maze,background,coordinates_in_left,bw_in_left, ...
            coordinates_out_left,bw_out_left,vid_cage,FrameRate,trial_length,exploration_threshold, ...
            initialization_threshold,thresh,cage_in_thresh,cage_out_thresh,reward_center, ...
            reward_on_maze,reward_radius,duration_range,duration_threshold,trial_num)

    case 6       % Observer mouse training.
        OL_obs_training(Folder,s,vid_maze,background,coordinates_in_right,bw_in_right, ...
            coordinates_out_right,bw_out_right,vid_cage,FrameRate,trial_length,exploration_threshold, ...
            initialization_threshold,thresh,cage_in_thresh,cage_out_thresh,reward_center, ...
            reward_on_maze,reward_radius,duration_range,duration_threshold,trial_num)

    case 7       % Observational learning multiple trials with tone.
        OL_multi_trials_w_tone(Folder,s,vid_maze,background,coordinates_in_left,bw_in_left, ...
            vid_cage,FrameRate,trial_length,exploration_threshold, ...
            initialization_threshold,thresh,cage_in_thresh,reward_center, ...
            reward_on_maze,reward_radius,duration_range,duration_threshold,trial_num)

    case 8       % Observer learning session.
        OL_obs_learning_session(Folder,s,vid_maze,background,coordinates_in_left,bw_in_left, ...
            coordinates_out_left,bw_out_left,vid_cage,FrameRate,trial_length,exploration_threshold, ...
            initialization_threshold,thresh,cage_in_thresh,cage_out_thresh,reward_center, ...
            reward_on_maze,reward_radius,duration_range,duration_threshold,trial_num)

    case 9       % Observer testing session.
        OL_obs_testing_session(Folder,s,vid_maze,background,coordinates_in_right,bw_in_right, ...
            coordinates_out_right,bw_out_right,vid_cage,FrameRate,trial_length,exploration_threshold, ...
            initialization_threshold,thresh,cage_in_thresh,cage_out_thresh,reward_center, ...
            reward_on_maze,reward_radius,duration_range,duration_threshold,trial_num)

    otherwise
        disp('Unexpected mode value.')
end

