%%
clear; close all; clc;

%% set the path for data.

Directory = 'E:\ETH_Zurich\Master_Thesis\CBM_data\session2\';    % Main directory\
date = 'day5_Jan_31_2023';
mouse_name = 'mouse_LLR';
type = 'obs';

%% calculate distance

trials = 5;

reward_interval = NaN(trials,1);
labels = NaN(trials,1);

for trial_num = 1:trials
% for trial_num = [1 3:trials]

    trial = ['trial' num2str(trial_num)];

    Data_Folder = [Directory date '\' mouse_name '_' type '\' trial '\'];

    load([Data_Folder 'step_timepoint.mat']);   % Load the mouse step timepoints.

    reward_interval(trial_num) = step_timepoint(4) - step_timepoint(2);

    if step_timepoint(4)<179.9
        labels(trial_num) = 1;
    else
        labels(trial_num) = 0;
    end

end
