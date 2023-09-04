%Spatial and Reward coding during Observational learning in mice

%Real-time image acquisition and mice tracking workflow:

%Left cage: Demo Mouse
%Right cage: Observer Mouse

%Open the matlab data acquisition toolbox to preview,then close preview.
%Change the saving file folders’ names;
%Check the serial port number of Arduino board;
%Start the video recording, take the first frame as background;
%Place the mice into cages;

%Run the full script, which automatically runs the whole trial:
%Step 1: To start the trial: open the cage door to release the mouse;
%Step 2: Each time the mice stay in the reward zone for 2 secs, food is dispensed
%        in cage, and a tone (10kHz) is played; After they picked up food in
%        cage, a new pellet is ready to be dispensed;
%Step 3: After maximum 3 mins, close the cage door when the mouse is detected entering the cage;

%Author:  Yihui Du
%Date: 	November 22th, 2022
%%
clear; close all; clc;

%% set the path for output data.
Directory = 'D:\yihui\CBM_data\';    % Main directory\
date = 'day0_Dec_14_2022';
mouse_name = 'test_mouse_R';
type = 'demo';

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

%% Get and save the background image

start(vid_maze);
pause(3)
background = getsnapshot(vid_maze);
stop(vid_maze);

Data_Folder = [Directory date '\' mouse_name '_' type '\'];
if ~exist(Data_Folder,'dir')
    mkdir(Data_Folder)
end
save([Data_Folder 'background.mat'],'background');

%% set the area coordinates of inner boundary for left cage

figure(1);
disp('Please draw the inner boundary for left cage, and double click to save the coordinates    ');
bw_in_left = roipoly(background);
[r_in_left,c_in_left] = find(bw_in_left==1);

left_in_x1 = min(c_in_left);
left_in_y1 = min(r_in_left(c_in_left == min(c_in_left)));

left_in_x2 = min(c_in_left(r_in_left == min(r_in_left)));
left_in_y2 = min(r_in_left);

left_in_x3 = max(c_in_left);
left_in_y3 = max(r_in_left(c_in_left == max(c_in_left)));

left_in_x4 = max(c_in_left(r_in_left == max(r_in_left)));
left_in_y4 = max(r_in_left);

coordinates_in_left = [left_in_x1 left_in_x2 left_in_x3 left_in_x4; ...
    left_in_y1 left_in_y2 left_in_y3 left_in_y4]';

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

%% Set the Tracking Parameters.

trial_length = 600; % 10 mins (600 secs)
exploration_threshold = 300; % 5 mins (300 secs)
initialization_threshold = 600; % 1 mins (60 secs)

thresh = 0.4;

% start(vid_maze);
% pause(3)
% ROI_frame = getsnapshot(vid_maze);  % acquisite the maze image
% stop(vid_maze);
%
% ROI_Im = imabsdiff(ROI_frame,background);
% cage_in_left = ROI_Im.*uint8(bw_in_left);
% cage_out_left = ROI_Im.*uint8(bw_out_left);
%
% cage_in_thresh = sum(cage_in_left,'all')+1000;
% cage_out_thresh = sum(cage_out_left,'all')+1000;

cage_in_thresh = 20000;
cage_out_thresh = 36000;

%%
A = 2; % Amplitude
f_0 = 4000; % Frequency of sound (4k Hz)
fs = 40000;   % Sampling frequency (40k Hz)
N = 40000;    % Signal sampling points number, Playback duration (1 secs)
y = A*sin(2*pi*f_0*(0:N-1)/fs); % Single frequency sine signal

Speaker_volume = 33;

%% Trial number

trial_num = '6';

reward_on_maze = 1;  % true(1) / false(0)

reward_radius = 45;  % 10 cm * pixel_size

duration_range = 3;  % previous 3 secs
reward_duration_range = duration_range*FrameRate;

duration_threshold = 2; % 2 secs
reward_duration_threshold = duration_threshold*FrameRate;

trial = ['trial' trial_num];

Data_Folder = [Directory date '\' mouse_name '_' type '\' trial '\'];

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

pellets = 0;
pellet_timepoint = 0;

Step_2 = 1;
Step_3 = 1;
pellet_collected = 1;

reward_duration = 0;
reward_timepoint = zeros(1,trial_length*FrameRate);

% start the trial

start(vid_maze);
t_vid_maze_Start = tic;

start(vid_cage);
t_vid_cage_Start = tic;

%Step 1: Open the left cage door to release the Demo mouse;
% cage door control
tStart = tic;

fprintf(s,'left_door_open/');
step_timepoint = toc(tStart);
disp('Step 1: Open the left cage door to release the Demo mouse    ');

while toc(tStart) < trial_length
    
    ROI_frame = getsnapshot(vid_maze);  % acquisite the maze image
    T(i)= toc(tStart);
    i = i + 1;
    
    ROI_Im = imabsdiff(ROI_frame,background);
    
    cage_in_left = ROI_Im.*uint8(bw_in_left);
    
    figure(1);
    imshow(ROI_frame);
    hold on
    
    %% Plot rectangular regions for two cages and circular area for reward
    
    patch('XData',[left_in_x1 left_in_x2 left_in_x3 left_in_x4],'YData',[left_in_y1 left_in_y2 left_in_y3 left_in_y4],...
        'EdgeColor','yellow','FaceColor','none','LineWidth',1);
    
    plot(reward_center(:,1),reward_center(:,2), 'b.');
    viscircles(reward_center,reward_radius,'Color','blue','LineWidth',0.4,'LineStyle','--');
    
    %% mouse in cage detection
    
    if sum(cage_in_left,'all') > cage_in_thresh % mouse is detected in the cage;
        patch('XData',[left_in_x1 left_in_x2 left_in_x3 left_in_x4],'YData',[left_in_y1 left_in_y2 left_in_y3 left_in_y4],...
            'EdgeColor','yellow','FaceColor','yellow','FaceAlpha',0.5,'LineWidth',1);
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
    
    %Step 2: Each time the mice stay in the reward zone for 2 secs, food is dispensed
    %        in cage, and a tone (10kHz) is played; After they picked up food in
    %        cage, a new pellet is ready to be dispensed;
    if Step_2
        if toc(tStart) < exploration_threshold
            if pdist([reward_center ; centroids],'euclidean') < reward_radius
                reward_timepoint(i) = 1;
                reward_duration = length(find(reward_timepoint(max([i-reward_duration_range,1]):i)));
                if reward_duration > reward_duration_threshold
                    if toc(tStart) > (pellet_timepoint + duration_range) && pellet_collected
                        fprintf(s,'left_food/');
                        pellet_timepoint = toc(tStart);
                        step_timepoint = [step_timepoint pellet_timepoint];
                        pellet_collected = 0;
                        pellets = pellets + 1;
                        disp('Step 2: Demo mouse is in the reward zone for 2 secs    ');
                        disp(['Provide food for the demo mouse (pellet '  num2str(pellets) ')    ']);
                        disp(['Pellet dispensed time: ',num2str(pellet_timepoint),' seconds.']);
                        
                        % play tone for pellet dispense (1 secs)
                        sound(y,fs);  % Sound playback through sound card
                    end
                end
                
            elseif ~pellet_collected && pellets > 0 && sum(cage_in_left,'all') > cage_in_thresh
                pellet_collected = 1;
                
            elseif toc(tStart) > initialization_threshold && pellets == 0 && sum(cage_in_left,'all') > cage_in_thresh
                fprintf(s,'left_door_close/');
                step_timepoint = [step_timepoint toc(tStart)];
                disp('Step 2: After 1 min without exiting the cage, close the cage door to end the trial    ');
                Step_2 = 0;
                break
            end
            
        else
            disp('Step 2: The mouse has exploring maze for 3 mins, let it back to cage    ');
            Step_2 = 0;
        end
        
        %Step 3: After maximum 3 mins, close the cage door when the mouse is detected entering the cage;
    elseif Step_3
        if sum(cage_in_left,'all') > cage_in_thresh
            fprintf(s,'left_door_close/');
            step_timepoint = [step_timepoint toc(tStart)];
            disp('Step 3: Close the left cage door, Demo mouse is in the left cage    ');
            Step_3 = 0;
            pause(3)  % wait for 10 secs
            fprintf(s,'left_door_close/');
            pause(7)  % wait for 10 secs
            break
        end
    end
    
end
tEnd = toc(tStart);
step_timepoint = [step_timepoint tEnd];
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
    'reward_timepoint','exploration_threshold','coordinates_in_left','pellets','T','Speaker_volume');

% imaqreset;
