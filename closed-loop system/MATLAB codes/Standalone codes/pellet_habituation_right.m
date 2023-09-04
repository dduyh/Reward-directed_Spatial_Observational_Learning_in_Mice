%Spatial and Reward coding during Observational learning in mice

%Left cage: Demo Mouse
%Right cage: Observer Mouse

%drop one pellet every 30 secs for observer mouse.

%Author:  Yihui Du
%Date: 	November 15th, 2022

%%
clear; close all; clc;

%% set the path for output data.
Directory = 'D:\yihui\CBM_data\';    % Main directory\
date = 'day7_Nov_23_2022';
mouse_name = 'mouse_L';
type = 'obs';
trial = 'trial1';

Data_Folder = [Directory date '\' mouse_name '_' type '\' trial '\'];
if ~exist(Data_Folder,'dir')
    mkdir(Data_Folder)
end

%% OPEN VIDEO INPUT (cages):
imaqreset
imaqmex('feature','-limitPhysicalMemoryUsage',false);
vid_cage = videoinput('tisimaq_r2013_64', 4, 'RGB24 (640x480) [Binning 2x]');
set(vid_cage,'Timeout',35);
vid_cage.FramesPerTrigger = Inf;
vid_cage.ReturnedColorspace = 'grayscale';
src_cage = getselectedsource(vid_cage);
src_cage.ExposureAuto = 'Off';
src_cage.Exposure = 0.066;
src_cage.GainAuto = 'Off';
src_cage.Gain = 0;

start(vid_cage);

FrameRate = 15;

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

%%
writerObj=VideoWriter([Data_Folder 'backup_video.avi']);
writerObj.FrameRate = FrameRate;
open(writerObj);

%%
tStart = tic;
n = 20;
T = zeros(1,n);

for i = 1:n
    
    fprintf(s,'Right_food/');
    disp(['Pellet: ',num2str(i),'/',num2str(n)]);
    %     pause(30)
    T(i)= toc(tStart);
    disp(['Elapsed time: ',num2str(T(i)),' seconds.']);
    
    T_temp = toc(tStart);
    
    while T_temp < 30*i
        ROI_frame = getsnapshot(vid_cage);  % acquisite the maze image
        figure(1);
        imshow(ROI_frame);
        
        frame = getframe;
        writeVideo(writerObj,frame);
        
        T_temp = toc(tStart);
    end
    
end
tEnd = toc(tStart);
disp(['Elapsed time: ',num2str(tEnd),' seconds.']);
%%
close(writerObj);

%%
stop(vid_cage);

diskLogger = VideoWriter([Data_Folder 'habituation_to_pellets.avi'], 'Uncompressed AVI');
diskLogger.FrameRate = FrameRate;
open(diskLogger);
data = getdata(vid_cage, vid_cage.FramesAvailable);
numFrames = size(data, 4);
for ii = 1:numFrames
    writeVideo(diskLogger, data(:,:,:,ii));
end
close(diskLogger);

save([Data_Folder 'times.mat'],'T');

%% reset all image acquisition connections.
imaqreset;

