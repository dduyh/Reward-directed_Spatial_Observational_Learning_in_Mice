# Function-Packaged codes for the real-time image acquisition and mice tracking system
## Main Function: OL_task_control_main.m
## Habituation session
1 Mode 1: Drop one pellet every 30 secs for demo mouse.

  &ensp; pellet_habituation_left.m

2 Mode 2: Drop one pellet every 30 secs for observer mouse.

  &ensp; pellet_habituation_right.m

3 Mode 3: Manully provide 5 pellets for 3 trials on/in the maze for demo mouse.

  &ensp; maze_cage_habituation_left.m

4 Mode 4: Manully provide 5 pellets for 3 trials on/in the maze for observer mouse.

  &ensp; maze_cage_habituation_right.m
  
## Single Mice Training session
1 Mode 5: Demo mouse training.

  &ensp; OL_demo_training.m
  
2 Mode 6: Observer mouse training.

  &ensp; OL_obs_training.m  
  
3 Mode 7: Demo mouse training multiple trials with tone. (optional)

  &ensp; OL_multi_trials_w_tone.m  


## Observational Learning session
1 Mode 8: Observer learning session.

  &ensp; OL_obs_learning_session.m

2 Mode 9: Observer testing session.

  &ensp; OL_obs_testing_session.m

## Parameters Setting functions
1 Arduino board initialization.

  &ensp; arduino_initialization.m

2 Initiate video of maze.

  &ensp; video_initialization_maze.m

3 Get background image. 

  &ensp; background_image.m  

4 Initiate video of cage.

  &ensp; video_initialization_cage.m

5 Get coordinates of inner boundary of left cage.

  &ensp; cage_coordinates_inner_left.m

6 Get coordinates of outer boundary of left cage.

  &ensp; cage_coordinates_outer_left.m

7 Get coordinates of inner boundary of right cage.

  &ensp; cage_coordinates_inner_right.m

8 Get coordinates of outer boundary of right cage.

  &ensp; cage_coordinates_outer_right.m

