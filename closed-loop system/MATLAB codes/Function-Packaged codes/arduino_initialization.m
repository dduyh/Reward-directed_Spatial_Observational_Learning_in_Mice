% Initialize the door and food dispenser controlled by arduino
function [s] = arduino_initialization(~)

delete(instrfindall);
s = serial('COM4');
set(s,'BaudRate',9600);
set(s,'Timeout',30);
set(s,'InputBufferSize',8388608);

fopen(s);
if (exist('board1','var'))
    board1.stop;pause(0);
end

