%%
clear; close all; clc;

%% set the path for data.

Directory = 'E:\ETH_Zurich\Master_Thesis\CBM_data\session3\';    % Main directory\
date = {'day1_Mar_17_2023' 'day2_Mar_18_2023' 'day3_Mar_19_2023' 'day5_Mar_21_2023' 'day6_Mar_22_2023'};
trial_length = [15 16 15 15 16];
colors = {[zeros([1,15]) 1];
    [0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 1];
    [1 1 0 1 1 0 1 1 0 1 1 0 1 1 0 1];
    [1 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1];
    [ones([1,7]) 0 ones([1,7]) 0 1]};

%% set the coordinates for maze

load([Directory date{1} '\' 'background.mat'], 'background')
figure(1);
imshow(background);
maze_coordinates = ginput(8);

pixel_size = 450;   % pixels/m

%%
xstart = 1;

for I=1:5

    mouse_name = {'mouse_LR' 'mouse_L' 'mouse_R' 'mouse_LL'};
    type = {'demo' 'obs' 'demo' 'obs'};

    trials = trial_length(I);

    distance = NaN(4,trials+1);

    % calculate distance

    for II=1:4
        % for II= [1 3 4]

        for trial_num = 1:trials
            % for trial_num = [1:5 7:trials]

            trial = ['trial' num2str(trial_num)];

            Data_Folder = [Directory date{I} '\' mouse_name{II} '_' type{II} '\' trial '\'];

            load([Data_Folder 'centers.mat']);   % Load the mouse coordinates data.

            if I == 2 && II == 2 && trial_num == 6
                continue
            end

            %             if exist(Data_Folder,'dir')
            %                 load([Data_Folder 'centers.mat']);   % Load the mouse coordinates data.
            %             else
            %                 continue
            %             end

            centers(all(centers==0,2),:) = [];
            in = inpolygon(centers(:,1),centers(:,2),maze_coordinates(:,1),maze_coordinates(:,2));
            centers(~in,:) = [];

            locomotion = zeros(1,numel(centers)-1);

            for i = 1 : size(centers,1)-1
                mouse_dist = [centers(i,1), centers(i,2); centers(i+1,1), centers(i+1,2)];
                locomotion(i) = pdist(mouse_dist, 'euclidean');
            end

            distance(II,trial_num) = sum(locomotion)./pixel_size;

        end

        mymap = [0 0 0; 1 0 0];
        c = colors{I};

        figure(2);

        % plot distance v.s. trials

        distance(II,end) = NaN;
        patch(xstart:xstart+trials , distance(II,:), c, 'EdgeColor','flat','LineWidth',2,'FaceAlpha',0.7,'EdgeAlpha',0.2);
        colormap(mymap);

        hold on

    end

    %
    figure(2);
    [S,M] = std(distance,'omitnan');
    SEM = S/sqrt(4);
    errorbar(xstart:xstart+trials , M, SEM, "Color","black",'LineWidth',1);
    patch(xstart:xstart+trials , M, c, 'EdgeColor','flat','Marker','o','MarkerFaceColor','flat','LineWidth',1.5,'MarkerSize',3);

    xstart = xstart+trials+1;

end

figure(2);
title('Learning Performance during Behavioral Shaping','FontSize',14,'FontWeight','bold')

xlim([-1 , xstart])
% xticks(0:2:xstart)
xticks([1:2:15 17:2:32 34:2:48 50:2:64 66:2:81])
xticklabels(num2str([1:2:15 1:2:16 1:2:15 1:2:15 1:2:16]'));

ylim([0 , 20])
xlabel('Learning (no.trials)','FontSize',12,'FontWeight','bold');
ylabel('Performance (distance, m)','FontSize',12,'FontWeight','bold')

xl = xline([0 16 33 49 65],'--b',{'Day 1','Day 2','Day 3','Day 4','Day 5'},'LineWidth',1,'LabelOrientation','horizontal','FontSize',14);

p(1) = plot(NaN,NaN,'k','Marker','o','MarkerFaceColor','k','LineWidth',2);
p(2) = plot(NaN,NaN,'r','Marker','o','MarkerFaceColor','r','LineWidth',2);
legend(p,'Food on maze','No food on maze','FontSize',14)
legend('boxoff')

%% save figure

savefig([Directory 'learning_performance.fig']);
f = getframe(gcf);
imwrite(f.cdata,[Directory 'learning_performance.png']);
