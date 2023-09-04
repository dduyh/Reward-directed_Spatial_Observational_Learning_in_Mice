%Spatial and Reward coding during Observational learning in mice

%Left cage: Demo Mouse
%Right cage: Observer Mouse

%Step 1: Manully provide 5 pellets on/in the maze;
%Step 2: Place the mice into left cage;
%Step 3: Provide one pellet in left cage;
%Step 4: Open the cage door to release the mouse;
%Step 5: Close the cage door when the mouse is detected leaving the cage;
%Step 6: After 5 mins, open the cage door to let the mouse back to cage;
%Step 7: Close the cage door when the mouse is detected entering the cage;
%Step 8: Provide food for the demo mouse, when the demo mouse enters the cage

%Author:  Yihui Du
%Date: 	November 15th, 2022

%%
function [] = maze_cage_habituation_right(Folder,s,vid_maze,background,coordinates_in_right, ...
                               bw_in_right,coordinates_out_right,bw_out_right,FrameRate,trial_length, ...
                               exploration_threshold,cage_in_thresh,cage_out_thresh,trial_num)
                           
trial = ['trial' trial_num];

Data_Folder = [Folder trial '\'];

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

Step_5 = 1;
Step_6 = 1;
Step_7 = 1;
Step_8 = 1;

% start the trial
start(vid_maze);

%Step 1: Manully provide pellets on/in the maze;
%Step 2: Place the mice into right cage;
%Step 3: Provide one pellet in right cage;
fprintf(s,'Right_food/');
disp('Step 3: Provide one pellet in right cage    ');
pause(30)

%Step 4: Open the cage door to release the mouse;
fprintf(s,'Right_door_open/');
disp('Step 4: Open the cage door to release the mouse    ');

tStart = tic;

while toc(tStart) < trial_length
    
    ROI_frame = getsnapshot(vid_maze);  % acquisite the maze image
    
    ROI_Im = imabsdiff(ROI_frame,background);
    
    cage_in_right = ROI_Im.*uint8(bw_in_right);
    cage_out_right = ROI_Im.*uint8(bw_out_right);
    
    figure(1);
    imshow(ROI_frame);
    hold on
    
    %% Plot rectangular regions for two cages and circular area for reward
    
    patch('XData',coordinates_in_right(1,:),'YData',coordinates_in_right(2,:),...
        'EdgeColor','yellow','FaceColor','none','LineWidth',1);
    
    patch('XData',coordinates_out_right(1,:),'YData',coordinates_out_right(2,:),...
        'EdgeColor','green','FaceColor','none','LineWidth',1);
    
    %% mouse in cage detection
    if sum(cage_in_right,'all') > cage_in_thresh % mouse is detected in the cage;
        patch('XData',coordinates_in_right(1,:),'YData',coordinates_in_right(2,:),...
            'EdgeColor','yellow','FaceColor','yellow','FaceAlpha',0.5,'LineWidth',1);
    end
    
    if sum(cage_out_right,'all') < cage_out_thresh % mouse is detected out the cage;
        patch('XData',coordinates_out_right(1,:),'YData',coordinates_out_right(2,:),...
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

% reset all image acquisition connections.
% imaqreset;

