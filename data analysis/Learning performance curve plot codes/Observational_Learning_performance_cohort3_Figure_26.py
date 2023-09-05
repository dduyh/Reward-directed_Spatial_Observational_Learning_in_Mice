# -*- coding: utf-8 -*-
"""
Created on Wed May 17 23:28:39 2023

@author: yihui
"""

# %%
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import pyplot

# %%
plt.style.use('seaborn-whitegrid')
palette = pyplot.get_cmap('Set1')
font1 = {'family': 'Times New Roman',
         'weight': 'normal',
         'size': 18,
         }

# %%
fig = plt.figure(figsize=(20, 10))
# iters = list(range(7))
iters_obs = list([1, 6, 11, 16, 21, 26])
iters_demo = list([2, 3, 4, 5, 7, 8, 9, 10, 12, 13, 14, 15, 17, 18, 19, 20, 22, 23, 24, 25])

alldata1 = []  # Obs Ctrl
data = np.array([5.28755895792663,	5.00290535753547,	2.75590912509277,	2.30124879706214,	11.0018306370441,	2.95725913849187])  # 单个数据
alldata1.append(data)
data=np.array([2.68786326752493,	3.82852218311838,	8.90205031451446,	5.27009530659605,	3.29221446297613,	3.20319333948253])
alldata1.append(data)
data=np.array([12.4222495285131,	4.70565074683966,	8.67711585142438,	10.6922424431498,	12.7866742160617,	2.13839978035858])
alldata1.append(data)
alldata1 = np.array(alldata1)


alldata2 = []  # Demo Ctrl
data = np.array([1.44785608910230,	1.16747445592251,	1.26148964958812,	1.11089580575437,	1.03891761040892,	3.02866440144589,	0.998203621110023,	0.947641746320093,	0.532827760471502,	0.924516767787037,	1.01282637519642,	1.30512460686289,	1.05214753973387,	1.08873792077407,	4.32351305326305,	0.980019070732194,	1.00033956908525,	1.27702376867460,	1.04564919805224,	0.982390737309663])  # 单个数据
alldata2.append(data)
data=np.array([2.32475188520372, 1.17101767439091,	1.61948384950092,	1.18563155752958,	1.78505698832062,	1.70253045655849,	1.24550582592135,	2.55444928849657,	1.34222170878015,	1.24286711428647,	1.36237953428109,	1.15556060358878,	1.27239617025937,	1.33910490798311,	1.17652982318840,	1.29971645333144,	1.17254073966563,	1.27735213267787,	1.16166190235354,	1.18493555635858])
alldata2.append(data)
alldata2 = np.array(alldata2)

alldata3 = []  # Obs 
data = np.array([7.81286714681274,	12.7348601887827,	14.9180284329509,	2.01431265601259,	7.31882284280739,	15.9625367932761])
alldata3.append(data)
data=np.array([3.58470117967138,	12.0281448208552,	7.90977325875097,	4.06988054184405,	3.75545837838735,	4.87712086921846])
alldata3.append(data)
data=np.array([4.20708491636106,	3.52872030832735,	8.55283783417107,	6.26149681760954,	10.2540308165422,	7.05971915488516])
alldata3.append(data)
alldata3 = np.array(alldata3)


alldata4 = []  # Demo 
data = np.array([1.18078739980603,	1.46741831755034,	1.09595487673614,	2.35946478979766,	1.07688132283721,	1.17443256897556,	1.25660403893270,	1.33034280960259,	1.06123148881374,	3.72500152924461,	2.49929945325815,	1.82176713084274,	2.50717420037651,	1.66713072543562,	1.68860224868698,	1.33665055695724,	2.05187622759319,	1.18051685045679,	1.14089640551902,	2.52065565962917])
alldata4.append(data)
data=np.array([2.35282681975072,	1.30814210870425,	1.26986457416505,	1.96961068272081,	1.25313831779683,	1.55778132957834,	1.22421778391446,	1.18021304820967,	1.34181960397836,	1.16693801294911,	1.27479457127957,	2.50643288519716,	1.72239228608211,	1.84276270829100,	1.80770110665979,	1.36089798986862,	1.20418863190844,	1.32996586765015,	1.15389175649147,	1.43828717814115])
alldata4.append(data)
alldata4 = np.array(alldata4)

# %%
# for i in range(2):
color = palette(2)  # 算法1颜色
ax = fig.add_subplot(1, 2, 1)
# avg=np.mean(alldata1,axis=0)
# std=np.std(alldata1,axis=0)

avg = np.nanmean(alldata3, axis=0)
std = np.nanstd(alldata3, axis=0)

r1 = list(map(lambda x: x[0]-x[1], zip(avg, std)))  # 上方差
r2 = list(map(lambda x: x[0]+x[1], zip(avg, std)))  # 下方差
ax.plot(iters_obs, avg, color=color, label="Observer", linewidth=3.0)
ax.fill_between(iters_obs, r1, r2, color=color, alpha=0.2)

color = palette(1)
avg = np.mean(alldata4, axis=0)
std = np.std(alldata4, axis=0)
r1 = list(map(lambda x: x[0]-x[1], zip(avg, std)))
r2 = list(map(lambda x: x[0]+x[1], zip(avg, std)))
ax.plot(iters_demo, avg, color=color, label="Demo", linewidth=3.0)
ax.fill_between(iters_demo, r1, r2, color=color, alpha=0.2)

ax.legend(loc='upper right', prop=font1)
ax.set_xlabel('Learning (no.trials)', fontsize=22)
ax.set_ylabel('Performance (distance, m)', fontsize=22)
ax.set_title("Observational Learning",fontsize=34)
ax.set_ylim([0, 15])

# %%
color = palette(2)  # 算法1颜色
ax = fig.add_subplot(1, 2, 2)
# avg=np.mean(alldata1,axis=0)
# std=np.std(alldata1,axis=0)

avg = np.nanmean(alldata1, axis=0)
std = np.nanstd(alldata1, axis=0)

r1 = list(map(lambda x: x[0]-x[1], zip(avg, std)))  # 上方差
r2 = list(map(lambda x: x[0]+x[1], zip(avg, std)))  # 下方差
ax.plot(iters_obs, avg, color=color, label="Observer", linewidth=3.0)
ax.fill_between(iters_obs, r1, r2, color=color, alpha=0.2)

color = palette(1)
avg = np.mean(alldata2, axis=0)
std = np.std(alldata2, axis=0)
r1 = list(map(lambda x: x[0]-x[1], zip(avg, std)))
r2 = list(map(lambda x: x[0]+x[1], zip(avg, std)))
ax.plot(iters_demo, avg, color=color, label="Demo", linewidth=3.0)
ax.fill_between(iters_demo, r1, r2, color=color, alpha=0.2)

ax.legend(loc='upper right', prop=font1)
ax.set_xlabel('Learning (no.trials)', fontsize=22)
ax.set_ylabel('Performance (distance, m)', fontsize=22)
ax.set_title("Control (Opaque)",fontsize=34)
ax.set_ylim([0, 15])

