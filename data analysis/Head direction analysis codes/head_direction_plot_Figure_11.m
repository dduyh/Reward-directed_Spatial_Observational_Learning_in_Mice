clc
clear
close all

%% load the data

Directory = 'E:\ETH_Zurich\Master_Thesis\CBM_data\Session2\';    % Main directory\
date = 'day7_Feb_02_2023';
mouse_name1 = 'mouse_L';
type1 = 'demo';
mouse_name2 = 'LL';
type2 = 'obs';

trial_num = '24';
trial = ['trial' trial_num];

Data_Folder = [Directory date '\' mouse_name1 '_' type1 '_' mouse_name2 '_' type2 '\' trial '\'];

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
numFrames = obj.NumFrames;
FrameRate = obj.FrameRate;

load([Data_Folder 'step_timepoint.mat']);   % Load the mouse step timepoints.

figure(2);

plot([1:numFrames]/FrameRate,theta,'LineWidth',1.5)
hold on
line([0,numFrames/FrameRate],[0,0],'Color','red','linestyle','--');

patch('XData',[step_timepoint(1), step_timepoint(1), step_timepoint(2), step_timepoint(2)],'YData',[-200, 200, 200, -200],...
            'EdgeColor','none','FaceColor','black','FaceAlpha',0.3);
patch('XData',[step_timepoint(2), step_timepoint(2), step_timepoint(4)-2, step_timepoint(4)-2],'YData',[-200, 200, 200, -200],...
            'EdgeColor','none','FaceColor','yellow','FaceAlpha',0.3);
patch('XData',[step_timepoint(4)-2, step_timepoint(4)-2, step_timepoint(4), step_timepoint(4)],'YData',[-200, 200, 200, -200],...
            'EdgeColor','none','FaceColor','magenta','FaceAlpha',0.3);
patch('XData',[step_timepoint(4), step_timepoint(4), step_timepoint(4)+1, step_timepoint(4)+1],'YData',[-200, 200, 200, -200],...
            'EdgeColor','none','FaceColor','red','FaceAlpha',0.5);
patch('XData',[step_timepoint(4)+1, step_timepoint(4)+1, step_timepoint(5), step_timepoint(5)],'YData',[-200, 200, 200, -200],...
            'EdgeColor','none','FaceColor','cyan','FaceAlpha',0.3);
patch('XData',[step_timepoint(5), step_timepoint(5), step_timepoint(5)+10, step_timepoint(5)+10],'YData',[-200, 200, 200, -200],...
            'EdgeColor','none','FaceColor','black','FaceAlpha',0.3);

hold off

set(gca,'YDir','reverse')
xlim([0 , numFrames/FrameRate])
ylim([-200 , 200])
yticks(-180:90:180)
xlabel('Time (s)','FontSize',12,'FontWeight','bold');
ylabel('Offset (\circ)','FontSize',12,'FontWeight','bold')
title(['Head Direction  mouse ' mouse_name1(7:end) ' ' type1 ' ' mouse_name2 ' ' type2 '  (' date(1:4) ' ' trial ')'],'FontSize',14,'FontWeight','bold') 

savefig([Data_Folder 'head_direction_timeseries.fig']);
f = getframe(gcf);
imwrite(f.cdata,[Data_Folder 'head_direction_timeseries.png']);

%% plot HD distribution

figure(1)
polarhistogram(deg2rad(theta(floor(step_timepoint(2)*FrameRate):ceil(step_timepoint(5)*FrameRate))),50,'FaceColor','red','FaceAlpha',.3)
ax = gca;
ax.ThetaLimMode = 'manual';
ax.ThetaLim = [-180 180];
ax.ThetaDir = 'clockwise';

title('Head Direction distribution','FontSize',14,'FontWeight','bold') 

savefig([Data_Folder 'head_direction.fig']);
f = getframe(gcf);
imwrite(f.cdata,[Data_Folder 'head_direction.png']);

% close(figure(1));
