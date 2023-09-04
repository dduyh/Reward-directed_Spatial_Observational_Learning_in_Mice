% OPEN VIDEO INPUT (maze):
function [vid_maze] = video_initialization_maze(~)

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
