close all; clear;

nSubj = 4;
subjAvgMat = zeros(2,4,nSubj);


for jj = 1:nSubj
    
    load(['data' num2str(jj) '.mat']);
    
    %make a new matrix for trials
    allTrials = randTrials(2:41,:);
    bouncedMat = zeros(40,1);
    
    % make bouncedMat a matrix of 90 which is 1 if participant answered
    % bounced, 0 elsehwere
    for ii = 1:length(solution)
        bouncedMat(ii) = strcmpi('Bounced', solution{ii});
    end
    
    % make allTrials a matrix which has whether it's bounced or not as well
    allTrials = [allTrials bouncedMat];
    
    % break the matrix into two matrices; one for each graph
    birdMat = allTrials(allTrials(:,1) == 1,:);
    carMat = allTrials(allTrials(:,1) == 2,:);
    
    % make a cell array which has all of above to use in a for loop later
    allMats = {birdMat, carMat};
    %titles = {'Circles Proportion', 'Squares Proportion', 'Images Proportion'};
    titles = {'Bird Proportion', 'Car Proportion'};
    % find the proportion that participant said bounced when sky vs road and swoosh vs ding
    figure;
    for ii = 1:2
        % above
        propTime1 = sum(allMats{ii}(allMats{ii}(:,2) == 1 & allMats{ii}(:,3) == 1,4))/sum(allMats{ii}(:,2) == 1 & allMats{ii}(:,3) == 1);
        propTime2 = sum(allMats{ii}(allMats{ii}(:,2) == 2 & allMats{ii}(:,3) == 1,4))/sum(allMats{ii}(:,2) == 2 & allMats{ii}(:,3) == 1);
        propTime3 = sum(allMats{ii}(allMats{ii}(:,2) == 1 & allMats{ii}(:,3) == 2,4))/sum(allMats{ii}(:,2) == 1 & allMats{ii}(:,3) == 2);
        propTime4 = sum(allMats{ii}(allMats{ii}(:,2) == 2 & allMats{ii}(:,3) == 2,4))/sum(allMats{ii}(:,2) == 2 & allMats{ii}(:,3) == 2);
        propBouncedDing = [propTime1 propTime2 ];
        propBouncedSwoosh = [propTime3 propTime4 ];
        
        subjAvgMat(:, 2*(ii-1)+1:2*(ii-1)+2,jj) = [propBouncedDing ; propBouncedSwoosh];
        
        hold on;
        %graph em
        subplot(1,2,ii);
        plot([1 2], propBouncedDing, '-*',[1 2], propBouncedSwoosh, '--*');
        title(titles{ii});
        set(gca, 'xtick', [1:2], 'xticklabel', {'Sky', 'Road'});
        xlabel('Background');
        ylabel('Proportion of "Bounce" Responses');
        legend('Ding Played', 'Swoosh Played');
        
        axis([1 2 0 1]);
    end
        hold off;


    
end

    averages = mean(subjAvgMat,3);
    standardDev = std(subjAvgMat, [], 3)/2;
    
    figure;
    subplot(1,2,1);
    
    for ii = 1:2
      subplot(1,2,ii);
      errorbar([1 2], averages(1, (2*(ii-1)+1):(2*(ii-1)+2)), standardDev(1,2*(ii-1)+1:2*(ii-1)+2));
            hold on;
        title(titles{ii});
        set(gca, 'xtick', [1:2], 'xticklabel', {'Sky', 'Road'});

      errorbar([1 2], averages(2, (2*(ii-1)+1):(2*(ii-1)+2)), standardDev(2,2*(ii-1)+1:2*(ii-1)+2));
    hold off;
            xlabel('Background');
        ylabel('Proportion of "Bounce" Responses');
        legend('Ding Played', 'Swoosh Played');
    end
   


