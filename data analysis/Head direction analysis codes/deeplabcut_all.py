# -*- coding: utf-8 -*-
"""
Created on Tue May 23 10:18:33 2023

@author: yihui
"""

#%% run DLC
import os
import deeplabcut

#
root_dir = 'E:/ETH_Zurich/Master_Thesis/CBM_data'
DLC_config = 'E:/ETH_Zurich/Master_Thesis/CBM_data/Session3/head_direction_control-yihui-2023-06-27/config.yaml'

ses_dir = os.path.join(root_dir + '/Session3')
if os.path.exists(ses_dir):
    date_dir = os.path.join(ses_dir + '/day13_Apr_02_2023')
    if os.path.exists(date_dir):
        sub_dir = os.path.join(date_dir + '/mouse_LR_demo_L_obs')
        # for trial in range(len(os.listdir(sub_dir))):
        for trial in [2,3,4,5,7,8,9,10,12,13,14,15,17,18,19,20,22,23,24,25]:
        # for trial in [2,3,4,5,6,8,9,10,11,12,15,16,17,18,20,21,22,23,24]:
            trial_dir = os.path.join(sub_dir + '/trial' + str(trial))
            if os.path.exists(trial_dir):
                behavior_file = os.path.join(trial_dir + '/shaping_to_cage.avi')
                if os.path.exists(behavior_file):
                    deeplabcut.analyze_videos(DLC_config, behavior_file, shuffle=1, gputouse=1, save_as_csv=True, videotype=".avi")
                    deeplabcut.create_labeled_video(DLC_config, behavior_file, draw_skeleton=True)
    
# root_dir = 'I:/2DAA/stitching';
# DLC_config = 'I:/2DAA_DLC/DLC_2DAA-RB-2022-02-16/config.yaml';
# subjects = 14;
# sub_list = list(range(1, subjects + 1));
# for sub in sub_list:
#     sub_dir = os.path.join(root_dir + '/subject' + str(sub))
#     if os.path.exists(sub_dir):
#         for ses in range(len(os.listdir(sub_dir))):
#             ses_dir = os.path.join(sub_dir + '/session' + str(ses+1));
#             if os.path.exists(ses_dir):
#                 behavior_dir = os.path.join(ses_dir + '/stitchedMovie.avi');
#                 if os.path.exists(behavior_dir):
#                     deeplabcut.analyze_videos(DLC_config, behavior_dir, shuffle = 1, save_as_csv=True, videotype=".avi")
# #                   deeplabcut.create_labeled_video(DLC_config, trial_dir, draw_skeleton=(True))
