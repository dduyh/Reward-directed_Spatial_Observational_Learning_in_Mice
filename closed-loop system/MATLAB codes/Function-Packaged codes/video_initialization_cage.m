% OPEN VIDEO INPUT (maze):
function [vid_cage] = video_initialization_cage(~)

vid_cage = videoinput('tisimaq_r2013_64', 4, 'RGB24 (640x480) [Binning 2x]');
set(vid_cage,'Timeout',35);
vid_cage.FramesPerTrigger = Inf;
vid_cage.ReturnedColorspace = 'grayscale';
src_cage = getselectedsource(vid_cage);
src_cage.ExposureAuto = 'Off';
src_cage.Exposure = 0.0666;
src_cage.GainAuto = 'Off';
src_cage.Gain = 0;

