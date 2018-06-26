Screen('Preference', 'SkipSyncTests', 1);
fast = 0;

%% Initialize path

prompt = {'Enter Directory. If already in directory, press 1','SubjectID','AgeGroup','Experimenter Name'};
titl = 'iCount Setup';
lines = 1;
answer = inputdlg(prompt, titl, lines);
progDir = answer{1};
if str2double(progDir) == 1; progDir = cd; else cd(strcat(progDir,'\'));end
SubjectID = answer{2};
AgeGroup=answer{3};
ExperimenterName = answer{4};

clockT=clock;
Date=strcat(num2str(clockT(2)),'_',num2str(clockT(3)));
ClockTime=strcat(num2str(clockT(4)),':',num2str(clockT(5)),':',num2str(clockT(6)));

fprintf('Initializing...')
addpath(genpath(progDir))
fprintf('.Done\n');

%BIACSetupPsychtoolbox();
%run D:\Programs\MATLAB\PsychToolbox\3.0.1\BIACSetupPsychtoolbox.m

%% Load output data

[a,b,outputData] = xlsread(strcat('sub-',SubjectID,'_task-main_beh-',Date,'.xlsx'));
outputData = outputData(2:end,:);

poldsfractals = outputData(:,13);
poldbfractals = outputData(:,14);
oldfaces = outputData(:,20);

%% Determine order and fractal orientation of presentation

fracassignvec = zeros(1,24);
for i=1:24
    fracassign = randi(24);
    while any(fracassign==fracassignvec)
        fracassign = randi(24);
    end
    fracassignvec(i) = fracassign;
end

for i=1:24
    a = rand(1);
    if a>.5
        fraclr(i) = 0; % old left
    else
        fraclr(i) = 1; % old right
    end
end

%% Determine which fractals to present

for i=1:12
    oldsfractals{i} = poldsfractals{i*6};
    oldbfractals{i} = poldbfractals{i*6};
end
oldfractals = [oldsfractals;oldbfractals];

for i=1:24
    if strcmp(oldfractals{i}(end-4),'a') || strcmp(oldfractals{i}(end-4),'b') || strcmp(oldfractals{i}(end-4),'c')
        oldfraclet{i} = oldfractals{i}(end-4);
    elseif strcmp(oldfractals{i}(end-4),'a') || strcmp(oldfractals{i}(end-4),'b') || strcmp(oldfractals{i}(end-4),'c')
        oldfraclet{i} = oldfractals{i}(end-4);
    end
end

poldsfracnum = outputData(:,29);
poldbfracnum = outputData(:,30);

for i=1:12
    oldsfracnum{i} = poldsfracnum{i*6};
    oldbfracnum{i} = poldbfracnum{i*6};
end
oldfracnum = [oldsfracnum;oldbfracnum];

for i=1:24
    if strcmp(oldfraclet{i},'a')
        newfraclet{i} = 'b';
    elseif strcmp(oldfraclet{i},'b')
        newfraclet{i} = 'a';
    end
end

for i=1:24
    newfractals{i} = strcat(pwd,'\Fractals\fractal',num2str(oldfracnum{i}),newfraclet{i},'.jpg');
end
%% Open the screen

AssertOpenGL;
KbName('UnifyKeyNames');

screens=Screen('Screens');
screenNumber=max(screens);
gray=GrayIndex(screenNumber);
white = [255 255 255];
[w, wRect]=Screen('OpenWindow',screenNumber, white); %full screen ahead

[x,y] = RectCenter(wRect);
Screen('TextFont',w, 'Arial');
Screen('TextSize',w, 25);
Screen('TextStyle', w, 0);

HideCursor();

%% Fractal Presentation

fracoutput{1,1} = 'SubjectID';
fracoutput{1,2} = 'AgeGroup';
fracoutput{1,3} = 'ExperimenterName';
fracoutput{1,4} = 'Date';
fracoutput{1,5} = 'ClockTime';
fracoutput{1,6} = 'Trial';
fracoutput{1,7} = 'NewFractal';
fracoutput{1,8} = 'OldFractal';
fracoutput{1,9} = 'Judgment';
fracoutput{1,10} = 'RT';
fracoutput{1,11} = 'OldFracSide';

for i=1:24
    
    oldfractal = oldfractals{fracassignvec(i)};
    newfractal = newfractals{fracassignvec(i)};
    if fraclr(i)==0 % old left
        img1 = imread(oldfractal);
        img2 = imread(newfractal);
        fracoutput{i+1,11} = 'l';
    else % old right
        img2 = imread(oldfractal);
        img1 = imread(newfractal);
        fracoutput{i+1,11} = 'r';
    end
    Screen('PutImage',w,img1,[x-300,y-120,x-60,y+120])
    Screen('PutImage',w,img2,[x+60,y-120,x+300,y+120])
    Screen('TextSize',w, 22);
    DrawFormattedText(w,'Which fractal are you more familiar with?','center',y+170,[0 0 0]);
    DrawFormattedText(w,'1',x-310,y+200,[0 0 0]);
    DrawFormattedText(w,'2',x-225,y+200,[0 0 0]);
    DrawFormattedText(w,'3',x-140,y+200,[0 0 0]);
    DrawFormattedText(w,'4',x-55,y+200,[0 0 0]);
    DrawFormattedText(w,'5',x+35,y+200,[0 0 0]);
    DrawFormattedText(w,'6',x+120,y+200,[0 0 0]);
    DrawFormattedText(w,'7',x+205,y+200,[0 0 0]);
    DrawFormattedText(w,'8',x+290,y+200,[0 0 0]);
    
    [timestamp, startrt]=Screen('Flip', w);  % start reaction time
    
    t = GetSecs; resp=' '; subjresp = 0;
    while strcmp(resp,' ')
        [keyIsDown,endrt,keyCode]=KbCheck;
        if keyIsDown
            resp=KbName(keyCode);
            dt=endrt-startrt;
            subjresp=resp(1);
            break;
        end
        t=GetSecs;
    end
    
    while KbCheck
    end
    
    WaitSecs(.1);
    
    if fraclr(i)==0 % old left
        judgment = 5-str2num(subjresp);
    else
        judgment = str2num(subjresp)-4;
    end
    
    
    % output
    fracoutput{i+1,1} = SubjectID;
    fracoutput{i+1,2} = AgeGroup;
    fracoutput{i+1,3} = ExperimenterName;
    fracoutput{i+1,4} = Date;
    fracoutput{i+1,5} = ClockTime;
    fracoutput{i+1,6} = i;
    fracoutput{i+1,7} = newfractal;
    fracoutput{i+1,8} = oldfractal;
    fracoutput{i+1,9} = judgment;
    fracoutput{i+1,10} = dt;
end

%% Determine face presentation order, old face numbers

faceassignvec = zeros(1,144);
for i=1:144
    faceassign = randi(144);
    while any(faceassign==faceassignvec)
        faceassign = randi(144);
    end
    faceassignvec(i) = faceassign;
end

for i=1:72
    if strcmp(oldfaces{i}(6),'.')
        oldfaceno(i) = str2num(oldfaces{i}(5));
    elseif strcmp(oldfaces{i}(7),'.')
        oldfaceno(i) = str2num(oldfaces{i}(5:6));
    else
        oldfaceno(i) = str2num(oldfaces{i}(5:7));
    end
end

%% Face Presentation

faceoutput{1,1} = 'SubjectID';
faceoutput{1,2} = 'AgeGroup';
faceoutput{1,3} = 'ExperimenterName';
faceoutput{1,4} = 'Date';
faceoutput{1,5} = 'ClockTime';
faceoutput{1,6} = 'Trial';
faceoutput{1,7} = 'face';
faceoutput{1,8} = 'OldNew';
faceoutput{1,9} = 'subjresp';
faceoutput{1,10} = 'RT';

for i=1:144
    faceno = faceassignvec(i);
    face = strcat('face',num2str(faceno),'.png');
    if any(faceno==oldfaceno);
        ON(i) = 1; % old
    else
        ON(i) = 0; % new
    end
    Screen('TextSize',w,30);
    img = imread(face);
    Screen('PutImage', w, img, [x-240, y-320, x+240, y-00])
    Screen('TextSize',w, 22);
    DrawFormattedText(w, '1', x-300, y+225, [0 0 0]);
    DrawFormattedText(w, 'Remember', x-365, y+272, [0 0 0]);
    DrawFormattedText(w, '2', x-100, y+225, [0 0 0]);
    DrawFormattedText(w, 'Strongly', x-145, y+272, [0 0 0]);
    DrawFormattedText(w, 'Familiar', x-145, y+315, [0 0 0]);
    DrawFormattedText(w, '3', x+100, y+225, [0 0 0], 0);
    DrawFormattedText(w, 'Weakly', x+60, y+272, [0 0 0]);
    DrawFormattedText(w, 'Familiar', x+55, y+315, [0 0 0]);
    DrawFormattedText(w, '4', x+300, y+225, [0 0 0]);
    DrawFormattedText(w, 'New Picture', x+230, y+272, [0 0 0]);
    [timestamp, startrt]=Screen('Flip', w);  % start reaction time
    
    t = GetSecs; resp=' '; subjresp = 0;
    while strcmp(resp,' ')
        [keyIsDown,endrt,keyCode]=KbCheck;
        if keyIsDown
            resp=KbName(keyCode);
            dt=endrt-startrt;
            subjresp=resp(1);
            break;
        end
        t=GetSecs;
    end
    
    while KbCheck
    end
    
    WaitSecs(.1);
    
    faceoutput{i+1,1} = SubjectID;
    faceoutput{i+1,2} = AgeGroup;
    faceoutput{i+1,3} = ExperimenterName;
    faceoutput{i+1,4} = Date;
    faceoutput{i+1,5} = ClockTime;
    faceoutput{i+1,6} = i;
    faceoutput{i+1,7} = face;
    faceoutput{i+1,8} = ON(i);
    faceoutput{i+1,9} = subjresp;
    faceoutput{i+1,10} = dt;
end

initpay = 15;

correst = sum(cell2mat(outputData(1:end,34)));
correstpay = .1*correst;

pickpay = .1*outputData{72,32};

totpayout = initpay+correstpay+pickpay;

payoutmessage1 = strcat('accumulated earnings: $',num2str(outputData{72,32}));
DrawFormattedText(w,payoutmessage1,'center',y-200,[0 0 0]);

DrawFormattedText(w,'$15.00 initial payout','center',y-50,[0 0 0]);
payoutmessage2 = strcat('+ $',num2str(pickpay),' for stock/bond choices (10% of accumulated earnings)');
DrawFormattedText(w,payoutmessage2,'center',y,[0 0 0]);
payoutmessage3 = strcat('+ $',num2str(correstpay),' for accuracy in estimating stock probability');
DrawFormattedText(w,payoutmessage3,'center',y+50,[0 0 0]);
DrawFormattedText(w,strcat('= $',num2str(totpayout),' total payout'),'center',y+100,[0 0 0]);
Screen('Flip',w);

filename1 = strcat('iCount_fracmemory_',SubjectID,'_',Date,'.xlsx');
filename2 = strcat('iCount_facememory_',SubjectID,'_',Date,'.xlsx');

xlswrite(filename1,fracoutput);
xlswrite(filename2,faceoutput);


while ~strcmp(resp, 'q')
    ListenChar(2);
    [endrt, keyCode, deltaSecs]=KbWait([],2);
    resp=KbName(keyCode);
end
resp=''; ListenChar();


Screen('CloseAll');