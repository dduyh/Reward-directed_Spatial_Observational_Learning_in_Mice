clc
clear
close all

%% set the path for data.

Directory = 'E:\ETH_Zurich\Master_Thesis\CBM_data\';    % Main directory\

cohort1_date = {'Session1\day10_Nov_28_2022\mouse_LL_demo_LR_obs';
    'Session1\day10_Nov_28_2022\mouse_R_demo_RR_obs';
    'Session1\day10_Nov_28_2022\mouse_LLR_demo_L_obs'};

cohort2_date = {'Session2\day6_Feb_01_2023\mouse_RR_demo_LL_obs';
        'Session2\day6_Feb_01_2023\mouse_LR_demo_R_obs';
        'Session2\day6_Feb_01_2023\mouse_L_demo_LLR_obs';
        'Session2\day7_Feb_02_2023\mouse_RR_demo_R_obs';
        'Session2\day7_Feb_02_2023\mouse_LR_demo_LLR_obs';
        'Session2\day7_Feb_02_2023\mouse_L_demo_LL_obs'};

%% Cohort1 Attention

cohort1_trials = {[2 4 5 8 9 17 18 23 24];
    [2 3 4 5 8 9 10 11 12 14 16 17 18 20 22 23 24];
    [5 6 8 9 11 12 15 17 18 20 21 23 24]};

cohort1_trials_num = 0;
for i = 1:size(cohort1_trials,1)
    cohort1_trials_num = cohort1_trials_num + numel(cohort1_trials{i});
end


cohort1_thetas = NaN(cohort1_trials_num,91);
k = 1;

for I=1:size(cohort1_date,1)

    for trial_num = cohort1_trials{I}

        trial = ['trial' num2str(trial_num)];

        Data_Folder = [Directory cohort1_date{I} '\' trial '\'];

        data = csvread([Data_Folder 'shaping_to_cageDLC_mobnet_100_head_directionMar2shuffle1_1000000.csv'],3,1);

        snout_x = data(:,1);
        snout_y = data(:,2);

        left_ear_x = data(:,4);
        left_ear_y = data(:,5);
        right_ear_x = data(:,7);
        right_ear_y = data(:,8);

        % HD Angle calculation

        center_x = (left_ear_x + right_ear_x)/2;
        center_y = (left_ear_y + right_ear_y)/2;

        vx = snout_x - center_x;
        vy = snout_y - center_y;
        d = sqrt(vx.^2 + vy.^2); % magnitude of vector
        ux = vx./d;
        uy = vy./d; % unit vector

        theta = atan2d(uy,ux);

        % get HD timeseries traces

        fileName = [Data_Folder 'shaping_to_cage.avi'];
        obj = VideoReader(fileName); % Read original video
        FrameRate = obj.FrameRate;

        load([Data_Folder 'step_timepoint.mat']);   % Load the mouse step timepoints.

        t_start = round(step_timepoint(5)*FrameRate) - 45;
        t_end = round(step_timepoint(5)*FrameRate) + 45;
        cohort1_thetas(k,:) = theta(t_start:t_end);
        k = k+1;

    end
end

cohort1_thetas_all = reshape(cohort1_thetas,[],1);

%% Cohort2 Transferable Attention

cohort2_transferable_trials = {[1 9 15];
    [2 7 8 9 10 11 16 22];
    [2 4 9 10 14 17 20]
    [2 4 6 8 10 22];
    [3 5 6 10 17 18 20 24];
    [6 11 15 16 24]};


cohort2_transferable_trials_num = 0;
for i = 1:size(cohort2_transferable_trials,1)
    cohort2_transferable_trials_num = cohort2_transferable_trials_num + numel(cohort2_transferable_trials{i});
end


cohort2_transferable_thetas = NaN(cohort2_transferable_trials_num,91);
k = 1;

for I=1:size(cohort2_date,1)

    for trial_num = cohort2_transferable_trials{I}

        trial = ['trial' num2str(trial_num)];

        Data_Folder = [Directory cohort2_date{I} '\' trial '\'];

        data = csvread([Data_Folder 'shaping_to_cageDLC_mobnet_100_head_directionMar2shuffle1_1000000.csv'],3,1);

        snout_x = data(:,1);
        snout_y = data(:,2);

        left_ear_x = data(:,4);
        left_ear_y = data(:,5);
        right_ear_x = data(:,7);
        right_ear_y = data(:,8);

        % HD Angle calculation

        center_x = (left_ear_x + right_ear_x)/2;
        center_y = (left_ear_y + right_ear_y)/2;

        vx = snout_x - center_x;
        vy = snout_y - center_y;
        d = sqrt(vx.^2 + vy.^2); % magnitude of vector
        ux = vx./d;
        uy = vy./d; % unit vector

        theta = atan2d(uy,ux);

        % get HD timeseries traces

        fileName = [Data_Folder 'shaping_to_cage.avi'];
        obj = VideoReader(fileName); % Read original video
        FrameRate = obj.FrameRate;

        load([Data_Folder 'step_timepoint.mat']);   % Load the mouse step timepoints.

        t_start = round(step_timepoint(4)*FrameRate) - 45;
        t_end = round(step_timepoint(4)*FrameRate) + 45;
        cohort2_transferable_thetas(k,:) = theta(t_start:t_end);
        k = k+1;

    end
end

cohort2_transferable_thetas_all = reshape(cohort2_transferable_thetas,[],1);

%% Cohort2 Sustained Attention

cohort2_sustained_trials = {[4 8 10 11 17];
    [4 5 13 19 20];
    [1 3 5 15 21]
    [12 16 17 23 24];
    [4 14 16 23];
    [10 17]};

cohort2_sustained_trials_num = 0;
for i = 1:size(cohort2_sustained_trials,1)
    cohort2_sustained_trials_num = cohort2_sustained_trials_num + numel(cohort2_sustained_trials{i});
end


cohort2_sustained_thetas = NaN(cohort2_sustained_trials_num,91);
k = 1;

for I=1:size(cohort2_date,1)

    for trial_num = cohort2_sustained_trials{I}

        trial = ['trial' num2str(trial_num)];

        Data_Folder = [Directory cohort2_date{I} '\' trial '\'];

        data = csvread([Data_Folder 'shaping_to_cageDLC_mobnet_100_head_directionMar2shuffle1_1000000.csv'],3,1);

        snout_x = data(:,1);
        snout_y = data(:,2);

        left_ear_x = data(:,4);
        left_ear_y = data(:,5);
        right_ear_x = data(:,7);
        right_ear_y = data(:,8);

        % HD Angle calculation

        center_x = (left_ear_x + right_ear_x)/2;
        center_y = (left_ear_y + right_ear_y)/2;

        vx = snout_x - center_x;
        vy = snout_y - center_y;
        d = sqrt(vx.^2 + vy.^2); % magnitude of vector
        ux = vx./d;
        uy = vy./d; % unit vector

        theta = atan2d(uy,ux);

        % get HD timeseries traces

        fileName = [Data_Folder 'shaping_to_cage.avi'];
        obj = VideoReader(fileName); % Read original video
        FrameRate = obj.FrameRate;

        load([Data_Folder 'step_timepoint.mat']);   % Load the mouse step timepoints.

        t_start = round(step_timepoint(4)*FrameRate) - 45;
        t_end = round(step_timepoint(4)*FrameRate) + 45;
        cohort2_sustained_thetas(k,:) = theta(t_start:t_end);
        k = k+1;

    end
end

cohort2_sustained_thetas_all = reshape(cohort2_sustained_thetas,[],1);
