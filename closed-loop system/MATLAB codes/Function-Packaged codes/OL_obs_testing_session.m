%Spatial and Reward coding during Observational learning in mice

%Observer testing session

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
function [] = OL_obs_testing_session(Folder,s,vid_maze,background,coordinates_in_right,bw_in_right, ...
                               coordinates_out_right,bw_out_right,vid_cage,FrameRate,trial_length,exploration_threshold, ...
                               initialization_threshold,thresh,cage_in_thresh,cage_out_thresh,reward_center, ...
                               reward_on_maze,reward_radius,duration_range,duration_threshold,trial_num)
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

%% Set the Tone Waveform

A = 2; % Amplitude
f_0 = 4000; % Frequency of sound (4k Hz)
fs = 40000;   % Sampling frequency (40k Hz)
N = 40000;    % Signal sampling points number, Playback duration (1 secs)
y = A*sin(2*pi*f_0*(0:N-1)/fs); % Single frequency sine signal

Speaker_volume = 33;

%% OPEN VIDEO OUTPUT :

writerObj=VideoWriter([Data_Folder 'processed_behavior.avi']);
writerObj.FrameRate = FrameRate;
open(writerObj);

%% Set the Tracking Parameters.

centroids = zeros(1,2);
centers = zeros(trial_length*FrameRate,2);

i = 1;
T = zeros(1,trial_length*FrameRate);

step_timepoint = zeros(1,6);

Step_2 = 1;
Step_4 = 1;
Step_5 = 1;

reward_duration = 0;
reward_timepoint = zeros(1,trial_length*FrameRate);
reward_duration_range = duration_range*FrameRate;
reward_duration_threshold = duration_threshold*FrameRate;

%% start the trial

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
    
    patch('XData',coordinates_in_right(1,:),'YData',coordinates_in_right(2,:),...
        'EdgeColor','yellow','FaceColor','none','LineWidth',1);
    
    patch('XData',coordinates_out_right(1,:),'YData',coordinates_out_right(2,:),...
        'EdgeColor','green','FaceColor','none','LineWidth',1);
    
    plot(reward_center(:,1),reward_center(:,2), 'b.');
    viscircles(reward_center,reward_radius,'Color','blue','LineWidth',0.4,'LineStyle','--');
    
    %% mouse in cage detection
    if sum(cage_in_right,'all') > cage_in_thresh % mouse is detected in the cage;
        patch('XData',coordinates_in_right(1,:),'YData',coordinates_in_right(2,:),...
            'EdgeColor','yellow','FaceColor','yellow','FaceAlpha',0.5,'LineWidth',1);
    end
    
    if sum(cage_out_right,'all') < cage_out_thresh % mouse is detected out the cage;
        patch('XData',coordinates_out_right(1,:),'YData',coordinates_out_right(2,:),...
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
                fprintf(s,'Right_food/');
                step_timepoint(4)= toc(tStart);
                disp('Step 4: Observer mouse is in the reward zone for 2 secs, provide food for the Observer mouse    ');

                % play tone for pellet dispense (1 secs)
                sound(y,fs);  % Sound playback through sound card
                Step_4 = 0; 
                
                pause(2)  % wait for 2 secs
                fprintf(s,'Right_door_open/');
                disp('Open the right cage door to let the mouse back to cage     ');
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
            disp('Step 5: Close the right cage door, Observer mouse is in the right cage    ');
            Step_5 = 0;
            pause(3)  % wait for 3 secs
            fprintf(s,'Right_door_close/');
            pause(7)  % wait for 7 secs
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
    'reward_timepoint','exploration_threshold','coordinates_in_right','coordinates_out_right','T','Speaker_volume');

% imaqreset;
