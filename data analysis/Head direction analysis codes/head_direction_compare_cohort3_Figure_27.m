clc
clear
close all

%% set the path for data.

Directory = 'E:\ETH_Zurich\Master_Thesis\CBM_data\Session3\';    % Main directory\

observation_date = {'day7_Mar_23_2023\mouse_LR_demo_L_obs';
    'day13_Apr_02_2023\mouse_LR_demo_LL_obs'};

control_date = {'day7_Mar_23_2023\mouse_LR_demo_LL_obs';
    'day13_Apr_02_2023\mouse_LR_demo_L_obs'};


%% Cohort3 Observation Transferable Attention

observation_transferable_trials = {[2 8 9 14 23];
    [2 8 9 10 14 17 20 23]};

observation_transferable_trials_num = 0;
for i = 1:size(observation_transferable_trials,1)
    observation_transferable_trials_num = observation_transferable_trials_num + numel(observation_transferable_trials{i});
end

observation_transferable_thetas = NaN(observation_transferable_trials_num,91);
k = 1;

for I=1:size(observation_date,1)

    for trial_num = observation_transferable_trials{I}

        trial = ['trial' num2str(trial_num)];

        Data_Folder = [Directory observation_date{I} '\' trial '\'];

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
        observation_transferable_thetas(k,:) = theta(t_start:t_end);
        k = k+1;

    end
end

observation_transferable_thetas_all = reshape(observation_transferable_thetas,[],1);

%% Cohort3 Observation Sustained Attention

observation_sustained_trials = {[3 5 7 15 17 18 24];
    [3 19 22]};

observation_sustained_trials_num = 0;
for i = 1:size(observation_sustained_trials,1)
    observation_sustained_trials_num = observation_sustained_trials_num + numel(observation_sustained_trials{i});
end

observation_sustained_thetas = NaN(observation_sustained_trials_num,91);
k = 1;

for I=1:size(observation_date,1)

    for trial_num = observation_sustained_trials{I}

        trial = ['trial' num2str(trial_num)];

        Data_Folder = [Directory observation_date{I} '\' trial '\'];

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
        observation_sustained_thetas(k,:) = theta(t_start:t_end);
        k = k+1;

    end
end

observation_sustained_thetas_all = reshape(observation_sustained_thetas,[],1);

%% Cohort3 Control Transferable Attention

control_transferable_trials = {[2 8 9 10 18];
    [4 5 9 10 17]};

control_transferable_trials_num = 0;
for i = 1:size(control_transferable_trials,1)
    control_transferable_trials_num = control_transferable_trials_num + numel(control_transferable_trials{i});
end

control_transferable_thetas = NaN(control_transferable_trials_num,91);
k = 1;

for I=1:size(control_date,1)

    for trial_num = control_transferable_trials{I}

        trial = ['trial' num2str(trial_num)];

        Data_Folder = [Directory control_date{I} '\' trial '\'];

        data = csvread([Data_Folder 'shaping_to_cageDLC_mobnet_100_head_direction_controlJun27shuffle1_255000.csv'],3,1);

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
        control_transferable_thetas(k,:) = theta(t_start:t_end);
        k = k+1;

    end
end

control_transferable_thetas_all = reshape(control_transferable_thetas,[],1);

%% Cohort3 Control Sustained Attention

control_sustained_trials = {[3 14];
    [2 3 7 12 14 15 20 25]};

control_sustained_trials_num = 0;
for i = 1:size(control_sustained_trials,1)
    control_sustained_trials_num = control_sustained_trials_num + numel(control_sustained_trials{i});
end

control_sustained_thetas = NaN(control_sustained_trials_num,91);
k = 1;

for I=1:size(control_date,1)

    for trial_num = control_sustained_trials{I}

        trial = ['trial' num2str(trial_num)];

        Data_Folder = [Directory control_date{I} '\' trial '\'];

        data = csvread([Data_Folder 'shaping_to_cageDLC_mobnet_100_head_direction_controlJun27shuffle1_255000.csv'],3,1);

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
        control_sustained_thetas(k,:) = theta(t_start:t_end);
        k = k+1;

    end
end

control_sustained_thetas_all = reshape(control_sustained_thetas,[],1);
