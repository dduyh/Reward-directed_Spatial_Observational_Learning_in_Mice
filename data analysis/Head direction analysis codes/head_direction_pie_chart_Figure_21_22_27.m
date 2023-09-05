% plot the pie chart

clc
clear
close all

%% cohort 1

labels = {'Sustained Attention to Reward','Inattentiveness'};

Sustained_Attention = 9 + 17 + 13;
Inattentiveness = 10 + 3 + 7;

X = [Sustained_Attention Inattentiveness];
trial_num = Sustained_Attention + Inattentiveness;

figure(1)
p = pie(X);
t = p(2);
t.FontSize = 14;
t = p(4);
t.FontSize = 14;

legend(labels,'FontSize',12,'Location','northeast');

title(['Attention Types for Cohort 1 (Reward ' num2str(trial_num) ' trials)'],'FontSize',14,'FontWeight','bold') 

%% cohort 2

labels = {'Transferable Attention','Sustained Attention','Inattentiveness'};

Transferable_Attention = 3 + 8 + 7 + 5 + 8 + 5;
Sustained_Attention = 5 + 5 + 5 + 5 + 4 + 2;
Inattentiveness = 8 + 7 + 7 + 10 + 8 + 10;

X = [Transferable_Attention Sustained_Attention Inattentiveness];
trial_num = Transferable_Attention + Sustained_Attention + Inattentiveness;

figure(2)
p = pie(X);
t = p(2);
t.FontSize = 14;
t = p(4);
t.FontSize = 14;
t = p(6);
t.FontSize = 14;

legend(labels,'FontSize',12,'Location','northeast');

title(['Attention Types for Cohort 2 (Observation ' num2str(trial_num) ' trials)'],'FontSize',14,'FontWeight','bold') 

%% cohort 2 & 3

labels = {'Transferable Attention','Sustained Attention','Inattentiveness'};

Transferable_Attention = 3 + 8 + 7 + 5 + 8 + 5 + 5 + 8;
Sustained_Attention = 5 + 5 + 5 + 5 + 4 + 2 + 7 + 3;
Inattentiveness = 8 + 7 + 7 + 10 + 8 + 10 + 8 + 9;

X = [Transferable_Attention Sustained_Attention Inattentiveness];
trial_num = Transferable_Attention + Sustained_Attention + Inattentiveness;

figure(2)
p = pie(X);
t = p(2);
t.FontSize = 14;
t = p(4);
t.FontSize = 14;
t = p(6);
t.FontSize = 14;

legend(labels,'FontSize',12,'Location','northeast');

title(['Attention Types for Cohort 2 & 3 (Observation ' num2str(trial_num) ' trials)'],'FontSize',14,'FontWeight','bold') 

%% cohort 3

labels = {'Transferable Attention','Sustained Attention','Inattentiveness'};

Transferable_Attention = 5 + 8;
Sustained_Attention = 7 + 3;
Inattentiveness = 8 + 9;

X = [Transferable_Attention Sustained_Attention Inattentiveness];
trial_num = Transferable_Attention + Sustained_Attention + Inattentiveness;

figure(2)
p = pie(X);
t = p(2);
t.FontSize = 14;
t = p(4);
t.FontSize = 14;
t = p(6);
t.FontSize = 14;

% legend(labels,'FontSize',12,'Location','northeast');

% title(['Attention Types for Cohort 3 (Observation ' num2str(trial_num) ' trials)'],'FontSize',14,'FontWeight','bold') 
title(['Observation ' num2str(trial_num) ' trials'],'FontSize',14,'FontWeight','bold') 

%% cohort 3 control

labels = {'Transferable Attention','Sustained Attention','Inattentiveness'};

Transferable_Attention = 5 + 5;
Sustained_Attention = 2 + 8;
Inattentiveness = 13 + 7;

X = [Transferable_Attention Sustained_Attention Inattentiveness];
trial_num = Transferable_Attention + Sustained_Attention + Inattentiveness;

figure(3)
p = pie(X);
t = p(2);
t.FontSize = 14;
t = p(4);
t.FontSize = 14;
t = p(6);
t.FontSize = 14;

legend(labels,'FontSize',12,'Location','northeast');

title(['Attention Types for Cohort 3 (Control ' num2str(trial_num) ' trials)'],'FontSize',14,'FontWeight','bold') 
% title(['Control ' num2str(trial_num) ' trials'],'FontSize',14,'FontWeight','bold') 

