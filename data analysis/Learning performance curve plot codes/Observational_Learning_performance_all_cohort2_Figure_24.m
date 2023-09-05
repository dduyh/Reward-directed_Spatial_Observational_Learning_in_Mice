%%
clear; close all; clc;

%% set the path for data.

Directory = 'F:\ETH_Zurich\Master_Thesis\CBM_data\Session2\';    % Main directory\

date = {'day6_Feb_01_2023\mouse_RR_demo_LL_obs';
        'day6_Feb_01_2023\mouse_LR_demo_R_obs';
        'day6_Feb_01_2023\mouse_L_demo_LLR_obs';
        'day7_Feb_02_2023\mouse_RR_demo_R_obs';
        'day7_Feb_02_2023\mouse_LR_demo_LLR_obs';
        'day7_Feb_02_2023\mouse_L_demo_LL_obs'};

demo_trials = {[1:5 7:11 13:17 19];
    [1:5 7:11 13:17 19:23];
    [1:5 7:11 14:17 19:23];
    [2:6 8:12 14:18 20:24];
    [2:6 8:12 14:18 20:24];
    [2:6 8:12 14:18 23:24]};

obs_trials = {[6 12 18];
    [6 12 18 24];
    [6 12 13 18 24];
    [1 7 13 19 25];
    [1 7 13 19 25];
    [1 7 13 19 20 21 22 25]};

%% set the coordinates for maze

load([Directory '\' 'background.mat'], 'background')
figure(1);
imshow(background);
maze_coordinates = ginput(8);

%% calculate distance

trials = 25;

distance = NaN(1,trials);

pixel_size = 450;  % pixels/m

for I=1:size(date,1)

    for trial_num = 1:trials

        trial = ['trial' num2str(trial_num)];

        Data_Folder = [Directory date{I} '\' trial '\'];

        if exist(Data_Folder,'dir')
            load([Data_Folder 'centers.mat']);   % Load the mouse coordinates data.
        else
            continue
        end

        centers(all(centers==0,2),:) = [];
        in = inpolygon(centers(:,1),centers(:,2),maze_coordinates(:,1),maze_coordinates(:,2));
        centers(~in,:) = [];

        locomotion = zeros(1,numel(centers)-1);

        for i = 1 : size(centers,1)-1
            mouse_dist = [centers(i,1), centers(i,2); centers(i+1,1), centers(i+1,2)];
            locomotion(i) = pdist(mouse_dist, 'euclidean');
        end

        distance(trial_num) = sum(locomotion)./pixel_size;
    end

    % plot distance v.s. trials

    figure(2);
    hold on

    p(1) = plot(demo_trials{I},distance(1,demo_trials{I}),'Color',[80./255 188./255 254./255 0.5],'Marker','o','MarkerFaceColor',[80./255 188./255 254./255],'LineWidth',3,'MarkerSize',5);
    p(2) = plot(obs_trials{I},distance(1,obs_trials{I}),'Color',[53./255 235./255 57./255 0.5],'Marker','o','MarkerFaceColor',[53./255 235./255 57./255],'LineWidth',3,'MarkerSize',5);

end

figure(2);
hold off

title('Observational Learning Performance for Cohort 2','FontSize',30,'FontWeight','bold')

legend(p,'Demo','Obs','FontSize',30)
legend('boxoff')

xlim([0 , trials+1])
xticks(0:2:trials)
ylim([0 , max(distance)+2])
xlabel('Learning (no.trials)','FontSize',30,'FontWeight','bold');
ylabel('Performance (distance, m)','FontSize',30,'FontWeight','bold')
axis square

%% save figure

savefig([Directory 'observational_learning_performance_cohort2.fig']);
f = getframe(gcf);
imwrite(f.cdata,[Directory 'observational_learning_performance_cohort2.png']);
