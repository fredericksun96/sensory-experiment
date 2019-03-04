%% setup
clear; close all;
AssertOpenGL;
KbName('UnifyKeyNames');
rand('seed',sum(clock*100)); % for octave
Screen('Preference', 'SkipSyncTests', 1);
exitNow = false;

%% define some colors
% colors
black = [0 0 0];
white = [255 255 255];
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];
gray = [128 128 128];


% determine trials

    %% Get subject ID
    subjID = 1;
    subjID = inputdlg('Enter subject ID: ', 'Subject ID');
    trialNum = 40;
    
try
    %% open a window
    %scrNum = max(Screen('Screens'));
    [win, screenRect] = Screen('OpenWindow',0,gray);
    [width, height] = RectSize(screenRect);
    [cx, cy] = RectCenter(screenRect);
    Screen('TextSize',win,36);
    HideCursor;
    ListenChar(2);
    Priority(MaxPriority(win));
    Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    Screen('Flip',win);
    
    
    %trials matrix goes here THIS IS JUST TESTING RIGHT NOW
    % determine trials
    % column 1 is shape (bird, car)
    % column 2 is background variable (road, sky)
    % column 3 is sound variable (beep or swoosh)
    
    levels = [2,2,2];
    trial = fullfact(levels);
    solution = cell(trialNum,1);
    
    %repeat five times
    trials = [trial;trial;trial;trial;trial];
    randTrials = zeros(trialNum + 1,3);
    randOrder = randperm(trialNum);
    
    randTrials(1,:)=[1 1 1];
    
    for x = 2:trialNum+1
        randTrials(x,:) = trials(randOrder(x-1),:);
    end
    
    
    %% load in textures for images and backgrounds
    [bird, ~, alpha] = imread('bird.png');
    bird(:, :, 4) = alpha;
    birdTex = Screen('MakeTexture', win, bird);
    
    [car, ~, alpha2] = imread('car.png');
    car(:,:,4) = alpha2;
    carTex = Screen('MakeTexture', win, car);
    
    % make cell array with textures
    objectTexs = {birdTex, carTex};
    
    road = imread('road.png');
    roadTex = Screen('MakeTexture', win, road);
    
    sky = imread('sky.jpg');
    skyTex = Screen('MakeTexture', win, sky);
    
    % make cell array with backgrounds
    bkgTexs = {skyTex , roadTex};

    
    for ii=1:trialNum+1
        
        %number of frames until objects hit the center
        framecount = 50; %CHANGE LATER
        currentframe = 0;

        
        % find the trajectory each thing needs to move to go through the center
        % will take 200 frames to get to the middle of the screen.
        xmove = cx / framecount;
        ymove = cy / framecount;
        % to find the frames til center, we find it then subtract 15 frames for 250ms
        % before it hits center
        
        %load in sounds
        beep = audioread('beep.wav');
        swoosh = audioread('swoosh.wav');
        
        % starting positions
        pos1 = [30, 30, 180,150];
        pos2 = [screenRect(3) - 180, 30, screenRect(3) - 30, 150];
        framestilcenter = floor(framecount-mean([pos1(2) pos1(4)])/ymove) - 15;
        
        if ii == 1
            DrawFormattedText(win,'Practice Trial: this is what you are going to see in the real experiment. You will see two objects moving, you will also hear one of two sounds: a beep, or a swoosh, and you will have the option to select whether they appeared to be bouncing or streaming. Press any key to start when you are ready.','center','center',white,50);
            Screen('Flip',win);
            
            KbStrokeWait;
            
            %% animate dots to go through center of the screen
            while pos1(2) < screenRect(4)
                %%  draw the starting images in initial positions
                
                Screen('DrawTexture', win, bkgTexs{randTrials(ii,2)}, [], screenRect);
                Screen('DrawTexture', win, objectTexs{randTrials(ii,1)}, [], pos1);
                Screen('DrawTexture', win, objectTexs{randTrials(ii,1)}, [], pos2);
                Screen('Flip', win);
                
                %% make things move by the right amount, then redraw
                pos1 = [pos1(1) + xmove, pos1(2) + ymove, pos1(3) + xmove, pos1(4) + ymove];
                pos2 = [pos2(1) - xmove, pos2(2) + ymove, pos2(3) - xmove, pos2(4) + ymove];
                
                currentframe = currentframe + 1;
                
                
                % when they collide, play ding
                % when collide is when pos1 == pos2.
                
                if currentframe == framestilcenter && randTrials(ii,3) == 1
                    sr = 44100;
                    p = audioplayer(beep,sr);
                    play(p);
                elseif currentframe == framestilcenter  && randTrials(ii,3) == 2
                    sr = 44100;
                    p = audioplayer(swoosh,sr);
                    play(p);
               end
            end
            ShowCursor;
            % collect input ? mouse clicks that are either in a box that says ?streaming? or ?bouncing?
            blueButtonRect = [cx-250,cy-50,cx-50,cy+50];
            redButtonRect = [cx+50,cy-50,cx+250,cy+50];
            Screen('FillRect',win,blue,blueButtonRect);
            Screen('FillRect',win,red,redButtonRect);
            DrawFormattedText(win,'Streamed','center','center',[],[],[],[],[],[],blueButtonRect);
            DrawFormattedText(win,'Bounced','center','center',[],[],[],[],[],[],redButtonRect);
            Screen('Flip',win);
            validClick = true;
            [x,y,buttons] = GetMouse;
            
            while validClick == true
                while ~any(buttons)
                    [x,y,buttons] = GetMouse;
                end
                
                while any(buttons)
                    [x,y,buttons] = GetMouse;
                    if x >= blueButtonRect(1) && x <= blueButtonRect(3) && y >= blueButtonRect(2) && y <= blueButtonRect(4)
                        % whatever trial it is answer is "Streamed"
                        validClick = false;
                    elseif x >= redButtonRect(1) && x <= redButtonRect(3) && y >= redButtonRect(2) && y <= redButtonRect(4)
                        % whatever trial it is answer is "Bounced"
                        validClick = false;
                    end
                end
            end
            
            DrawFormattedText(win,'Now begins the experiment. There will be 40 trials. Press any key to start when you are ready.','center','center',white,50);
            Screen('Flip',win);
            
            KbStrokeWait;
            
        else
            while pos1(2) < screenRect(4)
                %%  draw the starting images in initial positions
                
                Screen('DrawTexture', win, bkgTexs{randTrials(ii,2)}, [], screenRect);
                Screen('DrawTexture', win, objectTexs{randTrials(ii,1)}, [], pos1);
                Screen('DrawTexture', win, objectTexs{randTrials(ii,1)}, [], pos2);
                Screen('Flip', win);
                
                %% make things move by the right amount, then redraw
                pos1 = [pos1(1) + xmove, pos1(2) + ymove, pos1(3) + xmove, pos1(4) + ymove];
                pos2 = [pos2(1) - xmove, pos2(2) + ymove, pos2(3) - xmove, pos2(4) + ymove];
                
                currentframe = currentframe + 1;
                
                %% when they collide, play ding
                if currentframe == framestilcenter && randTrials(ii,3) == 1
                    sr = 44100;
                    p = audioplayer(beep,sr);
                    play(p);
                elseif currentframe == framestilcenter && randTrials(ii,3) == 2
                    sr = 44100;
                    p = audioplayer(swoosh,sr);
                    play(p);
                end
            end
            
            % ShowCursor;
            % collect input ? mouse clicks that are either in a box that says ?streaming? or ?bouncing?
            blueButtonRect = [cx-250,cy-50,cx-50,cy+50];
            redButtonRect = [cx+50,cy-50,cx+250,cy+50];
            exitButtonRect = [cx-50,cy+100,cx+50,cy+200];
            Screen('FillRect',win,blue,blueButtonRect);
            Screen('FillRect',win,red,redButtonRect);
            Screen('FillRect',win,white,exitButtonRect);
            DrawFormattedText(win,'Streamed','center','center',[],[],[],[],[],[],blueButtonRect);
            DrawFormattedText(win,'Bounced','center','center',[],[],[],[],[],[],redButtonRect);
            DrawFormattedText(win,'Exit','center','center',black,[],[],[],[],[],exitButtonRect);
            Screen('Flip',win);
            
            validClick = true;
            [x,y,buttons] = GetMouse;
            
            while validClick == true
                while ~any(buttons)
                    [x,y,buttons] = GetMouse;
                end
                
                while any(buttons)
                    [x,y,buttons] = GetMouse;
                    if x >= blueButtonRect(1) && x <= blueButtonRect(3) && y >= blueButtonRect(2) && y <= blueButtonRect(4)
                        % whatever trial it is answer is "Streamed"
                        solution{ii - 1} = 'Streamed';
                        validClick = false;
                    elseif x >= redButtonRect(1) && x <= redButtonRect(3) && y >= redButtonRect(2) && y <= redButtonRect(4)
                        % whatever trial it is answer is "Bounced"
                        solution{ii - 1} = 'Bounced';
                        validClick = false;
                        
                    elseif x >= exitButtonRect(1) && x <= exitButtonRect(3) && y >= exitButtonRect(2) && y <= exitButtonRect(4)
                        validClick = false;
                        sca;
                        break;
                        
                    end
                end
            end
        end
    end
    
    DrawFormattedText(win,'You have now completed the experiment. Thank you for your participation. Press any key to exit.','center','center',white,50);
    Screen('Flip',win);
    KbStrokeWait;
    
    %     % save input into something
         save(['data' num2str(subjID{1}) '.mat'], 'solution', 'randTrials');
    %     % close a window
    ListenChar(0);
    Priority(0);
    sca;
catch
    ListenChar(0);
    Priority(0);
    ShowCursor;
    sca;
    psychrethrow(psychlasterror);
end


