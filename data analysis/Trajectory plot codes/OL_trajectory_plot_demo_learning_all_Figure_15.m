%%
clear; close all; clc;

%% set the path for data.
Directory = 'F:\ETH_Zurich\Master_Thesis\CBM_data\Session2\';    % Main directory\
date = 'day5_Jan_31_2023';
mouse_name = 'mouse_LL';
type = 'obs';

%% load background image
load([Directory 'background.mat'], 'background')

%% set the center coordinates for rewards
figure(1);
imshow(background);
hold off

reward_center = ginput(1);

%% set the coordinates for maze
maze_coordinates = ginput(8);

%% 
figure(2);

h1 = axes;
tpos = [0.1732 0.1121 0.6515 0.8380];
set(h1, 'Position', tpos)
xlim(h1,[0 744])
ylim(h1,[0 480])
hold on

scatter(h1,reward_center(1),reward_center(2),100,'x','MarkerEdgeColor','r','MarkerFaceColor','r','LineWidth',2);
viscircles(h1,reward_center,45,'Color','red','LineWidth',2,'LineStyle','-');

set(h1,'YDir','reverse');

%%
trials = 5;

for trial_num = 1:trials

trial = ['trial' num2str(trial_num)];

Data_Folder = [Directory date '\' mouse_name '_' type '\' trial '\'];

load([Data_Folder 'centers.mat']); % Load the data.

centers(all(centers==0,2),:) = [];
in = inpolygon(centers(:,1),centers(:,2),maze_coordinates(:,1),maze_coordinates(:,2));
centers(~in,:) = [];

h2=axes;
set(h2, 'Position', tpos);
plot(h2,centers(:,1),centers(:,2),'k','LineWidth',1); % plot trajectory
xlim(h2,[0 744])
ylim(h2,[0 480])
set(h2,'YDir','reverse');
set(h2,'color','none','visible','off')

end

hold off

%%
% manually maximize figure window

savefig([Directory date '\' mouse_name '_' type '\' 'trajectory_raw.fig']);
f = getframe(gcf);
imwrite(f.cdata(200:750,570:1130,:),[Directory date '\' mouse_name '_' type '\' 'trajectory_raw.png']);

% close(figure(1));