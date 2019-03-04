close all; clear;

nSubj = 2;
subjAvgMat = zeros(2,9,nSubj);


for jj = 1:nSubj
    
    load(['data' num2str(jj) '.mat']);
    
    %make a new matrix for trials
    allTrials = randTrials(2:91,:);
    bouncedMat = zeros(90,1);
    
    % make bouncedMat a matrix of 90 which is 1 if participant answered
    % bounced, 0 elsehwere
    for ii = 1:length(solution)
        bouncedMat(ii) = strcmpi('Bounced', solution{ii});
    end
    
    % make allTrials a matrix which has whether it's bounced or not as well
    allTrials = [allTrials bouncedMat];
    
    % break the matrix into three matrices; one for each graph
    circleMat = allTrials(allTrials(:,1) == 1,:);
    squareMat = allTrials(allTrials(:,1) == 2,:);
    imgMat = allTrials(allTrials(:,1) == 3,:);
    
    % make a cell array which has all three of above to use in a for loop later
    allMats = {circleMat, squareMat, imgMat};
    titles = {'Circles Proportion', 'Squares Proportion', 'Images Proportion'};
    
    % find the proportion that participant said bounced when Time1 (-250ms
    % before center), Time2, Time3. Then put all of them in a matrix called
    % propBounced
    figure;
    for ii = 1:3
        % find the proportions in which the sound is either played before,
        % during after AND when the sound is either swoosh or a ding, and they
        % said it's a bounce. :)
        propTime1 = sum(allMats{ii}(allMats{ii}(:,2) == 1 & allMats{ii}(:,3) == 1,4))/sum(allMats{ii}(:,2) == 1 & allMats{ii}(:,3) == 1);
        propTime2 = sum(allMats{ii}(allMats{ii}(:,2) == 2 & allMats{ii}(:,3) == 1,4))/sum(allMats{ii}(:,2) == 2 & allMats{ii}(:,3) == 1);
        propTime3 = sum(allMats{ii}(allMats{ii}(:,2) == 3 & allMats{ii}(:,3) == 1,4))/sum(allMats{ii}(:,2) == 3 & allMats{ii}(:,3) == 1);
        propTime4 = sum(allMats{ii}(allMats{ii}(:,2) == 1 & allMats{ii}(:,3) == 2,4))/sum(allMats{ii}(:,2) == 1 & allMats{ii}(:,3) == 2);
        propTime5 = sum(allMats{ii}(allMats{ii}(:,2) == 2 & allMats{ii}(:,3) == 2,4))/sum(allMats{ii}(:,2) == 2 & allMats{ii}(:,3) == 2);
        propTime6 = sum(allMats{ii}(allMats{ii}(:,2) == 3 & allMats{ii}(:,3) == 2,4))/sum(allMats{ii}(:,2) == 3 & allMats{ii}(:,3) == 2);
        propBouncedDing = [propTime1 propTime2 propTime3];
        propBouncedSwoosh = [propTime4 propTime5 propTime6];
        
        subjAvgMat(:, 3*(ii-1)+1:3*(ii-1)+3,jj) = [propBouncedDing ; propBouncedSwoosh];
        
        hold on;
        %graph em
        subplot(1,3,ii);
        plot([-250 0 250], propBouncedDing,[-250 0 250], propBouncedSwoosh, '--');
        title(titles{ii});
        xlabel('Time Sound Played (ms)');
        ylabel('Proportion of "Bounce" Responses');
        
        axis([-250 250 0 1]);
    end
        hold off;


    
end

    averages = mean(subjAvgMat,3);
    standardDev = std(subjAvgMat, [], 3)/2;
    
    figure;
    subplot(1,3,1);
    
    for ii = 1:3
      subplot(1,3,ii);
      errorbar([-250 0 250], averages(1, (3*(ii-1)+1):(3*(ii-1)+3)), standardDev(1,3*(ii-1)+1:3*(ii-1)+3));
            hold on;

      errorbar([-250 0 250], averages(2, (3*(ii-1)+1):(3*(ii-1)+3)), standardDev(2,3*(ii-1)+1:3*(ii-1)+3));
    hold off;
    end
   


