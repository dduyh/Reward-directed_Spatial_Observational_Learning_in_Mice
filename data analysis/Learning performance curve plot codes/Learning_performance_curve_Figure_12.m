%%
clear; close all; clc;

%% set the path for data.

Directory = 'F:\ETH_Zurich\Master_Thesis\CBM_data\session3\';    % Main directory\
date = 'day12_Apr_01_2023';
mouse_name = 'mouse_R';
type = 'demo';

%% set the coordinates for maze

load([Directory date '\' 'background.mat'], 'background')
figure(1);
imshow(background);
maze_coordinates = ginput(8);

%% calculate distance

trials = 15;
% no_food = 5; 

distance = NaN(1,trials+1);
reward_interval = NaN(1,trials+1);
trial_duration = NaN(1,trials+1);

pixel_size = 450;  % pixels/m

for trial_num = 1:trials
% for trial_num = [1:7 9:trials]

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
mymap = [0 0 0; 1 0 0];
% c = [0 ones([1,4]) 0 ones([1,4]) 0 ones([1,9]) 0]; 
% c = [zeros([1,no_food]) ones([1,trials+1-no_food])]; 
c = [ones([1,15]) 0]; 

figure(2);
sgtitle(['mouse ' mouse_name(7:end) '  Learning Performance  (' date(1:5) ')'],'FontSize',14,'FontWeight','bold') 

%% plot distance v.s. trials

h1 = subplot(1,3,1);

distance(end) = NaN; 
patch(1:trials+1 , distance(1,:), c, 'EdgeColor','flat','Marker','o','MarkerFaceColor','flat','LineWidth',2);
colormap(mymap);
% plot(1:trials , distance(1,:),'k-o','LineWidth',2)

hold on
p(1) = plot(NaN,NaN,'k','Marker','o','MarkerFaceColor','k','LineWidth',2);
p(2) = plot(NaN,NaN,'r','Marker','o','MarkerFaceColor','r','LineWidth',2);
hold off
legend(p,'Food on maze','No food on maze')
legend('boxoff')

xlim([0 , trials+1])
xticks(0:2:trials)
ylim([0 , max(distance)+2])
xlabel('Learning (no.trials)','FontSize',12,'FontWeight','bold');
ylabel('Performance (distance, m)','FontSize',12,'FontWeight','bold')
axis square
% title(['mouse ' mouse_name(7:end) '  Learning Performance'])

% labels = [repmat(0.5,[1,5]) ones([1,5]) repmat(1.5,[1,5]) repmat(2,[1,5])]; 
% h4 = subplot(2,3,4);
% % set(h2, 'Position', [0.1300    0.0838    0.7750    0.0312])
% mymap = [0 0 0
%     0 0 1
%     0 1 0
%     1 0 0];
% imagesc(labels)
% colormap(h4,mymap);
% axis off
%% plot Reward Search Interval v.s. trials

% figure(3);
h2 = subplot(1,3,2);

reward_interval(end) = NaN; 
patch(1:trials+1 , reward_interval(1,:), c, 'EdgeColor','flat','Marker','o','MarkerFaceColor','flat','LineWidth',2);
colormap(mymap);
% plot(1:trials , reward_interval(1,:),'k-o','LineWidth',2)

hold on
p(1) = plot(NaN,NaN,'k','Marker','o','MarkerFaceColor','k','LineWidth',2);
p(2) = plot(NaN,NaN,'r','Marker','o','MarkerFaceColor','r','LineWidth',2);
hold off
legend(p,'Food on maze','No food on maze')
legend('boxoff')

xlim([0 , trials+1])
xticks(0:2:trials)
ylim([0 , max(reward_interval)+20])
xlabel('Learning (no.trials)','FontSize',12,'FontWeight','bold');
ylabel('Reward Search Interval (seconds)','FontSize',12,'FontWeight','bold')
axis square
% title(['mouse ' mouse_name(7:end) '  Learning Performance'])

%% plot Total Search Duration v.s. trials

% figure(4);
h3 = subplot(1,3,3);

trial_duration(end) = NaN; 
patch(1:trials+1 , trial_duration(1,:), c, 'EdgeColor','flat','Marker','o','MarkerFaceColor','flat','LineWidth',2);
colormap(mymap);
% plot(1:trials , trial_duration(1,:),'k-o','LineWidth',2)

hold on
p(1) = plot(NaN,NaN,'k','Marker','o','MarkerFaceColor','k','LineWidth',2);
p(2) = plot(NaN,NaN,'r','Marker','o','MarkerFaceColor','r','LineWidth',2);
hold off
legend(p,'Food on maze','No food on maze')
legend('boxoff')

xlim([0 , trials+1])
xticks(0:2:trials)
ylim([0 , max(trial_duration)+20])
xlabel('Learning (no.trials)','FontSize',12,'FontWeight','bold');
ylabel('Total Search Duration (seconds)','FontSize',12,'FontWeight','bold')
axis square
% title(['mouse ' mouse_name(7:end) '  Learning Performance'])

%% save figure

savefig([Directory date '\' mouse_name '_' type '\learning_performance.fig']);
f = getframe(gcf);
imwrite(f.cdata,[Directory date '\' mouse_name '_' type '\learning_performance.png']);
