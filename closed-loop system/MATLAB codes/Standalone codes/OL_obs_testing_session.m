%Spatial and Reward coding during Observational learning in mice

%Left cage: Demo Mouse
%Right cage: Observer Mouse

%Real-time image acquisition and mice tracking workflow:

%Open the matlab data acquisition toolbox to preview,then close preview.
%Change the saving file folders’ names;
%Check the serial port number of Arduino board;
%Start the video recording, take the first frame as background;
%Place the mice into cages;

%Run the full script, which automatically runs the whole trial:
%Step 1: To start the trial: open the cage door to release the Demo mouse;
%Step 2: Close the cage door when the Demo mouse is detected leaving the left cage;
%(Step 3: Provide food for the Observer mice, when the Demo mouse find the reward;)
%Step 4: After the Demo mouse finding the reward , open the cage door to let the mouse 
%        back to cage, and provide food for the demo mouse;
%        Or after maximum 3 mins, open the cage door to let the mouse back to cage;
%Step 5: Close the left cage door when the demo mouse is detected entering the cage

%Author:  Yihui Du
%Date: 	December 20th, 2022
%%
clear; close all; clc;

%% set the path for output data.
Directory = 'D:\yihui\CBM_data\';    % Main directory\
date = 'day8_Nov_24_2022';
mouse_name1 = 'mouse_LLR';
type1 = 'demo';
mouse_name2 = 'L';
type2 = 'obs';

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

%% OPEN VIDEO INPUT (maze):

imaqreset
imaqmex('feature','-limitPhysicalMemoryUsage',false);

vid_maze = videoinput('winvideo', 1, 'RGB24_744x480');
set(vid_maze,'Timeout',35);
vid_maze.FramesPerTrigger = Inf;
vid_maze.ReturnedColorspace = 'grayscale';
src_maze = getselectedsource(vid_maze);
src_maze.FrameRate = '15.0000';
src_maze.ExposureMode = 'manual';
src_maze.Exposure = -7;
src_maze.GainMode = 'manual';
src_maze.Gain = 16;

%% Get the background image

start(vid_maze);
pause(3)
background = getsnapshot(vid_maze);
stop(vid_maze);

Data_Folder = [Directory date '\' mouse_name1 '_' type1 '_' mouse_name2 '_' type2 '\'];
if ~exist(Data_Folder,'dir')
    mkdir(Data_Folder)
end
save([Data_Folder 'background.mat'],'background');

%%
% set the area coordinates of inner boundary for right cage
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

coordinates_in_right = [right_in_x1 right_in_x2 right_in_x3 right_in_x4; ...
    right_in_y1 right_in_y2 right_in_y3 right_in_y4];

%%
% set the area coordinates of outer boundary for right cage
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

coordinates_out_right = [right_out_x1 right_out_x2 right_out_x3 right_out_x4; ...
    right_out_y1 right_out_y2 right_out_y3 right_out_y4];

%% OPEN VIDEO INPUT (cages):

vid_cage = videoinput('tisimaq_r2013_64', 4, 'RGB24 (640x480) [Binning 2x]');
set(vid_cage,'Timeout',35);
vid_cage.FramesPerTrigger = Inf;
vid_cage.ReturnedColorspace = 'grayscale';
src_cage = getselectedsource(vid_cage);
src_cage.ExposureAuto = 'Off';
src_cage.Exposure = 0.0666;
src_cage.GainAuto = 'Off';
src_cage.Gain = 0;

FrameRate = 15;

%% set the center coordinates for rewards
figure(1);
imshow(background);
reward_center = ginput(1);

reward_on_maze = 0;  % true(1) / false(0)

reward_radius = 45;  % 10 cm * pixel_size

duration_range = 3;  % previous 3 secs
reward_duration_range = duration_range*FrameRate;

duration_threshold = 2; % 2 secs
reward_duration_threshold = duration_threshold*FrameRate;

%% Set the Tracking Parameters.

trial_length = 600; % 10 mins (600 secs)
exploration_threshold = 180; % 3 mins (180 secs)
initialization_threshold = 60; % 1 mins (60 secs)

thresh = 0.4;
cage_in_thresh = 20000;
cage_out_thresh = 36000;

%% Trial number

trial_num = '6';

trial = ['trial' trial_num];


Data_Folder = [Directory date '\' mouse_name1 '_' type1 '_' mouse_name2 '_' type2 '\' trial '\'];

if exist(Data_Folder,'dir')
    % Ask user if they want to overwrite the file.
    promptMessage = sprintf('This directory already exists:\n%s\nDo you want to overwrite it?', Data_Folder);
    titleBarCaption = 'Overwrite?';
    buttonText = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
    if strcmpi(buttonText, 'No')
        % User does not want to overwrite.
        error('trial number already exists')
    else
        close;
    end
else
    mkdir(Data_Folder)
end

% OPEN VIDEO OUTPUT :

writerObj=VideoWriter([Data_Folder 'processed_behavior.avi']);
writerObj.FrameRate = FrameRate;
open(writerObj);

% Set the Tracking Parameters.

centroids = zeros(1,2);
centers = zeros(trial_length*FrameRate,2);

i = 1;
T = zeros(1,trial_length*FrameRate);

step_timepoint = zeros(1,6);

Step_2 = 1;
Step_4 = 1;
Step_5 = 1;

%
reward_duration = 0;
reward_timepoint = zeros(1,trial_length*FrameRate);

% start the trial

start(vid_maze);
t_vid_maze_Start = tic;

start(vid_cage);
t_vid_cage_Start = tic;

%Step 1: Open the right cage door to release the Observer mouse;
% cage door control
tStart = tic;

fprintf(s,'Right_door_open/');
step_timepoint(1)= toc(tStart);
disp('Step 1: Open the right cage door to release the Observer mouse    ');

while toc(tStart) < trial_length
    
   
    ROI_frame = getsnapshot(vid_maze);  % acquisite the maze image
    T(i)= toc(tStart);
    i = i + 1;
    
    ROI_Im = imabsdiff(ROI_frame,background);
    
    cage_in_right = ROI_Im.*uint8(bw_in_right);
    cage_out_right = ROI_Im.*uint8(bw_out_right);
    
    figure(1);
    imshow(ROI_frame);
    hold on
    
    %% Plot rectangular regions for two cages and circular area for reward
    
    patch('XData',[right_in_x1 right_in_x2 right_in_x3 right_in_x4],'YData',[right_in_y1 right_in_y2 right_in_y3 right_in_y4],...
        'EdgeColor','yellow','FaceColor','none','LineWidth',1);
    
    patch('XData',[right_out_x1 right_out_x2 right_out_x3 right_out_x4],'YData',[right_out_y1 right_out_y2 right_out_y3 right_out_y4],...
        'EdgeColor','green','FaceColor','none','LineWidth',1);
    
    plot(reward_center(:,1),reward_center(:,2), 'b.');
    viscircles(reward_center,reward_radius,'Color','blue','LineWidth',0.4,'LineStyle','--');
    
    %% mouse in cage detection
    if sum(cage_in_right,'all') > cage_in_thresh
        patch('XData',[right_in_x1 right_in_x2 right_in_x3 right_in_x4],'YData',[right_in_y1 right_in_y2 right_in_y3 right_in_y4],...
            'EdgeColor','yellow','FaceColor','yellow','FaceAlpha',0.5,'LineWidth',1);
    end

    if sum(cage_out_right,'all') < cage_out_thresh
        patch('XData',[right_out_x1 right_out_x2 right_out_x3 right_out_x4],'YData',[right_out_y1 right_out_y2 right_out_y3 right_out_y4],...
            'EdgeColor','green','FaceColor','green','FaceAlpha',0.3,'LineWidth',1);
    end
    
    %% find the mouse center
    
    I = im2bw(ROI_Im,thresh);
    k = regionprops('table',I,'Area');
    idx = find(max([k.Area]));
    cc = bwconncomp(I);
    g = ismember(labelmatrix(cc), idx);
    m = regionprops('table',g,'Area','Centroid','MajorAxisLength','MinorAxisLength');
    if(size(m,1)==1)
        
        centroids = cat(1, m.Centroid);
        centers(i,:) = centroids;
        
        plot(centroids(:,1),centroids(:,2), 'r.')
        diameters = mean([m.MajorAxisLength m.MinorAxisLength],2);
        radii = diameters/2;
        viscircles(centroids,radii,'LineWidth',0.1);
    end
    hold off
    
    frame2 = getframe;
    writeVideo(writerObj,frame2);
    
    
    %% Control the door and food dispenser
  
    %Step 2: Close the right cage door when the Observer mouse is detected leaving the right cage;
    if Step_2
        if sum(cage_out_right,'all') < cage_out_thresh
            fprintf(s,'Right_door_close/');
            step_timepoint(2)= toc(tStart);
            disp('Step 2: Close the right cage door, Observer mouse is leaving the right cage    ');
            Step_2 = 0;
                        
        elseif toc(tStart) > initialization_threshold
            fprintf(s,'Right_door_close/');
            step_timepoint(2)= toc(tStart);
            disp('Step 2: After 1 min, close the cage door to end the trial    ');
            Step_2 = 0;
            break
        end
        
        %(Step 3: Provide food for the observer mice, when the demo mouse find the reward)
        
        %Step 4: After the mouse finding the reward , open the cage door to let the mouse 
        %back to cage, and provide food for the demo mouse;
        %Or after maximum 5 mins, open the cage door to let the mouse back to cage;
    elseif Step_4
        if pdist([reward_center ; centroids],'euclidean') < reward_radius
            reward_timepoint(i) = 1;
            reward_duration = length(find(reward_timepoint(max([i-reward_duration_range,1]):i)));
            if reward_duration > reward_duration_threshold
                fprintf(s,'Right_door_open/');
                step_timepoint(4)= toc(tStart);
                disp('Step 4: Open the right cage door, Observer mouse is in the reward zone for 2 secs    ');
                Step_4 = 0; 
                
                pause(2)  % wait for 2 secs
                fprintf(s,'Right_food/');
                disp('Provide food for the Observer mouse    ');
            end
            
        elseif toc(tStart) > exploration_threshold
            fprintf(s,'Right_door_open/');
            step_timepoint(4)= toc(tStart);
            disp('Step 4: After 3 mins, open the cage door to let the mouse back to cage    ');
            Step_4 = 0;
        end
        
        %Step 5: Close the right cage door when the Observer mouse is detected entering the right cage;
    elseif Step_5
        if sum(cage_in_right,'all') > cage_in_thresh
            fprintf(s,'Right_door_close/');
            step_timepoint(5)= toc(tStart);
%             back_timepoint = toc(tStart);
            disp('Step 5: Close the right cage door, Observer mouse is in the right cage    ');
            Step_5 = 0;
            pause(3)  % wait for 10 secs
            fprintf(s,'Right_door_close/');
            pause(7)  % wait for 10 secs
            break
        end
      
    end
    
    
end
tEnd = toc(tStart);
step_timepoint(6)= tEnd;
disp(['Elapsed time: ',num2str(tEnd),' seconds.']);

close(writerObj);

stop(vid_maze);
t_vid_maze_End = toc(t_vid_maze_Start);

stop(vid_cage);
t_vid_cage_End = toc(t_vid_cage_Start);

close(figure(1));

% save maze video
data = getdata(vid_maze, vid_maze.FramesAvailable);
numFrames = size(data, 4);

diskLogger = VideoWriter([Data_Folder 'shaping_to_maze.avi'], 'Uncompressed AVI');
diskLogger.FrameRate = numFrames./t_vid_maze_End;
open(diskLogger);
for ii = 1:numFrames
    writeVideo(diskLogger, data(:,:,:,ii));
end
close(diskLogger);

% save cage video
data = getdata(vid_cage, vid_cage.FramesAvailable);
numFrames = size(data, 4);

diskLogger = VideoWriter([Data_Folder 'shaping_to_cage.avi'], 'Uncompressed AVI');
diskLogger.FrameRate = numFrames./t_vid_cage_End;
open(diskLogger);
for ii = 1:numFrames
    writeVideo(diskLogger, data(:,:,:,ii));
end
close(diskLogger);

% save data files 
save([Data_Folder 'centers.mat'],'centers');
save([Data_Folder 'step_timepoint.mat'],'step_timepoint');
save([Data_Folder 'parameters.mat'],'reward_center','reward_radius','duration_threshold','reward_on_maze', ...
    'reward_timepoint','exploration_threshold','coordinates_in_right','coordinates_out_right','T');

% imaqreset;
