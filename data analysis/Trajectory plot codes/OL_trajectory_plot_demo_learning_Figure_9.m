%%
clear; close all; clc;

%% set the path for data.
Directory = 'E:\ETH_Zurich\Master_Thesis\CBM_data\Session1\';    % Main directory\
date = 'day1_Nov_17_2022';
mouse_name = 'mouse_LLR';
type = 'demo';

%% load background image
% load([Directory 'background.mat'], 'background')

%% set the center coordinates for rewards
figure(1);
imshow(background);
reward_center = ginput(1);

%% set the coordinates for maze
maze_coordinates = ginput(8);

%%
trial_num = '4';

trial = ['trial' trial_num];

Data_Folder = [Directory date '\' mouse_name '_' type '\' trial '\'];

% Load the data.

load([Data_Folder 'centers.mat']);

centers(all(centers==0,2),:) = [];
in = inpolygon(centers(:,1),centers(:,2),maze_coordinates(:,1),maze_coordinates(:,2));
centers(~in,:) = [];

load([Data_Folder 'step_timepoint.mat']);

% plot background

hf=figure(1);

h1 = axes;
colormap(h1,'gray');
p1=imshow(background);
tpos = [0.1732 0.1121 0.6515 0.8380];
set(h1, 'Position', tpos)
hold on

scatter(reward_center(1),reward_center(2),60,'x','MarkerEdgeColor','r','MarkerFaceColor','r');
viscircles(reward_center,45,'Color','red','LineWidth',0.4,'LineStyle','--');

% title and labels
str1 = ['mouse ' mouse_name(7:end) '  (trial ' num2str(trial_num) ')'];
str2 = 'Demo Training session';
title({str1 ; str2});

str3 = sprintf('Demo leaves at %.1f s, stays in reward zone at %.1f s, back to cage at %.1f s', ...
    step_timepoint(2),step_timepoint(4),step_timepoint(5));


interval = step_timepoint(4) - step_timepoint(2);
duration = step_timepoint(5) - step_timepoint(2);
str4 = sprintf('Reward Search Interval = %.1f s,    Total Search Duration = %.1f s',interval,duration);

str5 = sprintf('Reward Zone Staying %.1f s,   No food on maze,   ',0.5);

if step_timepoint(4)<179.9
    str5 = [str5 'Successful Trial'];
else
    str5 = [str5 'Failed Trial'];
end

xlabel({str3 ; str4 ; str5},'FontSize',12,'FontWeight','bold')

% plot trajectory

centers(end,2) = NaN; 

h2=axes;
set(h2, 'Position', tpos);
set(h2,'YDir','reverse');
p2=patch(h2,centers(:,1),centers(:,2), 1:size(centers,1), 'EdgeColor','interp','LineWidth',2);
xlim(h2,[0 744])
ylim(h2,[0 480])

set(h2,'color','none','visible','off')
colormap(h2,'parula');
hBar = colorbar(h2,'east');
hBar.Label.String = 'Time (frames)';
hBar.Label.FontSize = 12;
get(hBar, 'Position');
set(hBar, 'Position', [0.85,0.25,0.014,0.6]);
set(hBar, 'AxisLocation', 'out');

hold off

%%
% manually maximize figure window

savefig([Data_Folder 'trajectory.fig']);
f = getframe(gcf);
imwrite(f.cdata(:,570:1270,:),[Data_Folder 'trajectory.png']);

% close(figure(1));