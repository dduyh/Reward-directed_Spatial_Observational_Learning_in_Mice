%Spatial and Reward coding during Observational learning in mice

%Left cage: Demo Mouse
%Right cage: Observer Mouse

%drop one pellet every 30 secs for demo mouse.

%Author:  Yihui Du
%Date: 	November 15th, 2022

%%
function [] = pellet_habituation_left(Folder,s,vid_cage,FrameRate,trial_num)

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

%%
writerObj=VideoWriter([Data_Folder 'backup_video.avi']);
writerObj.FrameRate = FrameRate;
open(writerObj);

%%
tStart = tic;
n = 20;
T = zeros(1,n);

start(vid_cage);

for i = 1:n

    fprintf(s,'left_food/');
    disp(['Pellet: ',num2str(i),'/',num2str(n)]);
    %     pause(30)
    T(i)= toc(tStart);
    disp(['Elapsed time: ',num2str(T(i)),' seconds.']);

    T_temp = toc(tStart);

    % play tone for pellet dispense (1 secs)
    sound(y,fs);  % Sound playback through sound card

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

close(writerObj);

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

% reset all image acquisition connections.
% imaqreset;

