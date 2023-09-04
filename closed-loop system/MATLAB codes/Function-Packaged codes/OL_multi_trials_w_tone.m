%Spatial and Reward coding during Observational learning in mice

%Observational learning multiple trials with tone.

%Run the full script, which automatically runs the whole trial:
%Step 1: To start the trial: open the cage door to release the mouse;
%Step 2: Each time the mice stay in the reward zone for 2 secs, food is dispensed
%        in cage, and a tone (10kHz) is played; After they picked up food in
%        cage, a new pellet is ready to be dispensed;
%Step 3: After maximum 3 mins, close the cage door when the mouse is detected entering the cage;

%Author:  Yihui Du
%Date: 	November 22th, 2022
%%
function [] = OL_multi_trials_w_tone(Folder,s,vid_maze,background,coordinates_in_left,bw_in_left, ...
                               vid_cage,FrameRate,trial_length,exploration_threshold, ...
                               initialization_threshold,thresh,cage_in_thresh,reward_center, ...
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

% Set the Tone Waveform

A = 2; % Amplitude
f_0 = 4000; % Frequency of sound (4k Hz)
fs = 40000;   % Sampling frequency (40k Hz)
N = 40000;    % Signal sampling points number, Playback duration (1 secs)
y = A*sin(2*pi*f_0*(0:N-1)/fs); % Single frequency sine signal

Speaker_volume = 33;

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
pellet_collected = 1; % flag for pellet ready to be collected on maze

Step_2 = 1;
Step_3 = 1;

reward_duration = 0;
reward_timepoint = zeros(1,trial_length*FrameRate);
reward_duration_range = duration_range*FrameRate;
reward_duration_threshold = duration_threshold*FrameRate;

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
    
    patch('XData',coordinates_in_left(1,:),'YData',coordinates_in_left(2,:),...
        'EdgeColor','yellow','FaceColor','none','LineWidth',1);
    
    plot(reward_center(:,1),reward_center(:,2), 'b.');
    viscircles(reward_center,reward_radius,'Color','blue','LineWidth',0.4,'LineStyle','--');
    
    %% mouse in cage detection
    
    if sum(cage_in_left,'all') > cage_in_thresh % mouse is detected in the cage;
        patch('XData',coordinates_in_left(1,:),'YData',coordinates_in_left(2,:),...
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
