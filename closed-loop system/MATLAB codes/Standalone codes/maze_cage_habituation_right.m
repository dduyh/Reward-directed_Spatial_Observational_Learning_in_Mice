%Spatial and Reward coding during Observational learning in mice

%Left cage: Demo Mouse
%Right cage: Observer Mouse

%Step 1: Manully provide 5 pellets on/in the maze;
%Step 2: Place the mice into right cage;
%Step 3: Provide one pellet in right cage;
%Step 4: Open the cage door to release the mouse;
%Step 5: Close the cage door when the mouse is detected leaving the cage;
%Step 6: After 5 mins, open the cage door to let the mouse back to cage;
%Step 7: Close the cage door when the mouse is detected entering the cage;
%Step 8: Provide food for the demo mouse, when the demo mouse enters the cage

%Author:  Yihui Du
%Date: 	November 23rd, 2022
%%
clear; close all; clc;

%% set the path for output data.
Directory = 'D:\yihui\CBM_data\';    % Main directory\
date = 'day7_Nov_23_2022';
mouse_name = 'mouse_L';
type = 'obs';
trial = 'trial4';

Data_Folder = [Directory date '\' mouse_name '_' type '\' trial '\'];
if ~exist(Data_Folder,'dir')
    mkdir(Data_Folder)
end

%% OPEN VIDEO INPUT (maze):

imaqreset
vid_maze = videoinput('winvideo', 1, 'RGB24_744x480');
vid_maze.FramesPerTrigger = Inf;
vid_maze.ReturnedColorspace = 'grayscale';
src_maze = getselectedsource(vid_maze);
src_maze.FrameRate = '15.0000';
src_maze.ExposureMode = 'manual';
src_maze.Exposure = -7;
src_maze.GainMode = 'manual';
src_maze.Gain = 16;

start(vid_maze);

FrameRate = 15;

%%
writerObj=VideoWriter([Data_Folder 'processed_behavior.avi']);
writerObj.FrameRate = FrameRate;
open(writerObj);

%% Initialize the door and food dispenser controlled by arduino
delete(instrfindall);
s = serial('COM4');
set(s,'BaudRate',9600);
set(s,'Timeout',30);
set(s,'InputBufferSize',8388608);

fopen(s);
if (exist('board1','var'))
    board1.stop;pause(0);
end

%% Set the Tracking Parameters.

trial_length = 480; % 8 mins (480 secs)
exploration_threshold = 300; % 5 mins (300 secs)

cage_in_thresh = 20000;
cage_out_thresh = 35000;

Step_5 = 1;
Step_6 = 1;
Step_7 = 1;
Step_8 = 1;

%% start the trial

background = getsnapshot(vid_maze);

if ~exist([Directory date '\' mouse_name '_' type '\'],'dir')
    mkdir([Directory date '\' mouse_name '_' type '\'])
end
save([Directory date '\' mouse_name '_' type '\' 'background.mat'],'background');

%%
% set the area coordinates for right cage
figure(1);
bw_in_right=roipoly(background);
[r_in_right,c_in_right]=find(bw_in_right==1);

right_in_x1 = min(c_in_right);
right_in_y1 = min(r_in_right(c_in_right == min(c_in_right)));

right_in_x2 = min(c_in_right(r_in_right == min(r_in_right)));
right_in_y2 = min(r_in_right);

right_in_x3 = max(c_in_right);
right_in_y3 = max(r_in_right(c_in_right == max(c_in_right)));

right_in_x4 = max(c_in_right(r_in_right == max(r_in_right)));
right_in_y4 = max(r_in_right);

%%
% set the area coordinates for right cage
figure(1);
bw_out_right=roipoly(background);
[r_out_right,c_out_right]=find(bw_out_right==1);

right_out_x1 = min(c_out_right);
right_out_y1 = min(r_out_right(c_out_right == min(c_out_right)));

right_out_x2 = min(c_out_right(r_out_right == min(r_out_right)));
right_out_y2 = min(r_out_right);

right_out_x3 = max(c_out_right);
right_out_y3 = max(r_out_right(c_out_right == max(c_out_right)));

right_out_x4 = max(c_out_right(r_out_right == max(r_out_right)));
right_out_y4 = max(r_out_right);

%%
%Step 1: Manully provide pellets on/in the maze;
%Step 2: Place the mice into right cage;
%Step 3: Provide one pellet in right cage;
fprintf(s,'Right_food/');
disp('Step 3: Provide one pellet in Right cage    ');
pause(30)

%Step 4: Open the cage door to release the mouse;
fprintf(s,'Right_door_open/');
disp('Step 4: Open the Right cage door to release the mouse    ');

tStart = tic;

while toc(tStart) < trial_length
    
    ROI_frame = getsnapshot(vid_maze);  % acquisite the maze image
    
    ROI_Im = imabsdiff(ROI_frame,background);
    
    cage_in_right = ROI_Im.*uint8(bw_in_right);
    cage_out_right = ROI_Im.*uint8(bw_out_right);
    
%     figure(2);
%     imshow(ROI_Im);
    
    figure(1);
    imshow(ROI_frame);
    hold on
    
    %% Plot rectangular regions for two cages and circular area for reward
    
    patch('XData',[right_in_x1 right_in_x2 right_in_x3 right_in_x4],'YData',[right_in_y1 right_in_y2 right_in_y3 right_in_y4],...
        'EdgeColor','yellow','FaceColor','none','LineWidth',1);
    
    patch('XData',[right_out_x1 right_out_x2 right_out_x3 right_out_x4],'YData',[right_out_y1 right_out_y2 right_out_y3 right_out_y4],...
        'EdgeColor','green','FaceColor','none','LineWidth',1);
    
    %% mouse in cage detection
    if sum(cage_in_right,'all') > cage_in_thresh
        patch('XData',[right_in_x1 right_in_x2 right_in_x3 right_in_x4],'YData',[right_in_y1 right_in_y2 right_in_y3 right_in_y4],...
            'EdgeColor','yellow','FaceColor','yellow','FaceAlpha',0.5,'LineWidth',1);
    end

    if sum(cage_out_right,'all') < cage_out_thresh
        patch('XData',[right_out_x1 right_out_x2 right_out_x3 right_out_x4],'YData',[right_out_y1 right_out_y2 right_out_y3 right_out_y4],...
            'EdgeColor','green','FaceColor','green','FaceAlpha',0.3,'LineWidth',1);
    end
    
    hold off
    
    frame = getframe;
    writeVideo(writerObj,frame);
    
    
    %% Control the door and food dispenser
    
    %Step 5: Close the cage door when the mouse is detected leaving the cage;
    if Step_5
        if sum(cage_out_right,'all') < cage_out_thresh
            fprintf(s,'Right_door_close/');
            disp('Step 5: Close the cage door when the mouse is detected leaving the cage    ');
            Step_5 = 0;
        end
        
        %Step 6: After 5 mins, open the cage door to let the mouse back to cage;
    elseif Step_6 
        if toc(tStart) > exploration_threshold
            fprintf(s,'Right_door_open/');
            disp('Step 6: After 5 mins, open the cage door to let the mouse back to cage    ');
            Step_6 = 0;
        end
        
        %Step 7: Close the cage door when the mouse is detected entering the cage;
    elseif Step_7
        if sum(cage_in_right,'all') > cage_in_thresh
            fprintf(s,'Right_door_close/');
            back_timepoint = toc(tStart);
            disp('Step 7: Close the cage door when the mouse is detected entering the cage    ');
            Step_7 = 0;
        end
        
        %Step 8: Provide food for the demo mouse, when the demo mouse enters the cage
    elseif Step_8
        if toc(tStart) > (back_timepoint + 2) % wait for 2 secs
            fprintf(s,'Right_food/');
            disp('Step 8: Provide food for the demo mouse, when the demo mouse enters the cage    ');
            Step_8 = 0;
        end
    end
    
    
end
tEnd = toc(tStart);
disp(['Elapsed time: ',num2str(tEnd),' seconds.']);
close(writerObj);
close(figure(1));
close(figure(2));

%%
stop(vid_maze);

diskLogger = VideoWriter([Data_Folder 'habituation_to_maze.avi'], 'Uncompressed AVI');
diskLogger.FrameRate = FrameRate;
open(diskLogger);
data = getdata(vid_maze, vid_maze.FramesAvailable);
numFrames = size(data, 4);
for ii = 1:numFrames
    writeVideo(diskLogger, data(:,:,:,ii));
end
close(diskLogger);

%% reset all image acquisition connections.
imaqreset;

