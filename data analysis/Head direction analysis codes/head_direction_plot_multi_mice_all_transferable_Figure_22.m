clc
clear
close all

%% set the path for data.

Directory = 'E:\ETH_Zurich\Master_Thesis\CBM_data\Session2\';    % Main directory\

date = {'day6_Feb_01_2023\mouse_RR_demo_LL_obs';
        'day6_Feb_01_2023\mouse_LR_demo_R_obs';
        'day6_Feb_01_2023\mouse_L_demo_LLR_obs';
        'day7_Feb_02_2023\mouse_RR_demo_R_obs';
        'day7_Feb_02_2023\mouse_LR_demo_LLR_obs';
        'day7_Feb_02_2023\mouse_L_demo_LL_obs'};

trials = {[1 2 3 4 5 7 8 9 10 11 13 14 15 16 17 19];
    [1 2 3 4 5 7 8 9 10 11 13 14 15 16 17 19 20 21 22 23];
    [1 2 3 4 5 7 8 9 10 11 14 15 16 17 19 20 21 22 23]
    [2 3 4 5 6 8 9 10 11 12 14 15 16 17 18 20 21 22 23 24];
    [2 3 4 5 6 8 9 10 11 12 14 15 16 17 18 20 21 22 23 24];
    [2 3 4 5 6 8 9 10 11 12 14 15 16 17 18 23 24]};

% trials = {[1 9 15];
%     [2 7 8 9 10 11 16 22];
%     [2 4 9 10 14 17 20]
%     [2 4 6 8 10 22];
%     [3 5 6 10 17 18 20 24];
%     [6 11 15 16 24]};

trials_num = 0;
for i = 1:size(trials,1)
    trials_num = trials_num + numel(trials{i});
end

%%

thetas = NaN(trials_num,91);
k = 1;

for I=1:size(date,1)

    for trial_num = trials{I}

        trial = ['trial' num2str(trial_num)];

        Data_Folder = [Directory date{I} '\' trial '\'];

        data = csvread([Data_Folder 'shaping_to_cageDLC_mobnet_100_head_directionMar2shuffle1_1000000.csv'],3,1);

        snout_x = data(:,1);
        snout_y = data(:,2);

        left_ear_x = data(:,4);
        left_ear_y = data(:,5);
        right_ear_x = data(:,7);
        right_ear_y = data(:,8);

        %% HD Angle calculation

        center_x = (left_ear_x + right_ear_x)/2;
        center_y = (left_ear_y + right_ear_y)/2;

        vx = snout_x - center_x;
        vy = snout_y - center_y;
        d = sqrt(vx.^2 + vy.^2); % magnitude of vector
        ux = vx./d;
        uy = vy./d; % unit vector

        theta = atan2d(uy,ux);

        %% plot HD timeseries traces

        fileName = [Data_Folder 'shaping_to_cage.avi'];
        obj = VideoReader(fileName); % Read original video
        FrameRate = obj.FrameRate;

        load([Data_Folder 'step_timepoint.mat']);   % Load the mouse step timepoints.

        t_start = round(step_timepoint(4)*FrameRate) - 45;
        t_end = round(step_timepoint(4)*FrameRate) + 45;
        thetas(k,:) = theta(t_start:t_end);
        k = k+1;

        figure(1);
        plot((0:90)/15,theta(t_start:t_end),'Color',[0.2 0.5 0.9 0.8],'LineWidth',0.8)
        hold on

    end
end

figure(1);
plot((0:90)/15,mean(thetas),'Color','black','LineWidth',2)

line([0,6],[0,0],'Color','red','linestyle','--');

patch('XData',[0, 0, 1, 1],'YData',[-200, 200, 200, -200],'EdgeColor','none','FaceColor','yellow','FaceAlpha',0.1);
patch('XData',[1, 1, 3,3],'YData',[-200, 200, 200, -200],'EdgeColor','none','FaceColor','magenta','FaceAlpha',0.1);
patch('XData',[3, 3, 4, 4],'YData',[-200, 200, 200, -200],'EdgeColor','none','FaceColor','red','FaceAlpha',0.2);
patch('XData',[4, 4, 6, 6],'YData',[-200, 200, 200, -200],'EdgeColor','none','FaceColor','cyan','FaceAlpha',0.1);

hold off

set(gca,'YDir','reverse')
xlim([0 , 6])
ylim([-200 , 200])
yticks(-180:90:180)
xlabel('Time (s)','FontSize',12,'FontWeight','bold');
ylabel('Offset (\circ)','FontSize',12,'FontWeight','bold')
% title('Transferable Attention HD Timeseries (Cue)' ,'FontSize',14,'FontWeight','bold')
title('Head Direction Timeseries (Cue)' ,'FontSize',14,'FontWeight','bold')

savefig([Directory '\' 'head_direction_timeseries.fig']);
f = getframe(gcf);
imwrite(f.cdata,[Directory '\' 'head_direction_timeseries.png']);
