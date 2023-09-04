% Get the background image
function [background] = background_image(vid_maze,Folder)

start(vid_maze);
pause(3)
background = getsnapshot(vid_maze);
stop(vid_maze);

if ~exist(Folder,'dir')
    mkdir(Folder)
end
save([Folder 'background.mat'],'background');