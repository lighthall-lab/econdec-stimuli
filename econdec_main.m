fast = 0;%
facegendervec=[zeros(1,72),ones(1,72)];

% Start at $25.00
initpay = 25;

%% Initialize path

prompt = {'SubjectID','AgeGroup','Experimenter Name'};
title = 'EconDec Setup';
answer = inputdlg(prompt, title, 1);

SubjectID = answer{1};
AgeGroup=answer{2};
ExperimenterName = answer{3};
progDir = cd;

% create output directory, set output filename
output_dir = fullfile(cd,['sub-',SubjectID]);
mkdir(output_dir);
filename = fullfile(output_dir,['sub-',SubjectID,'_task-main_beh.xlsx']);

clockT=clock;
Date=strcat(num2str(clockT(2)),'_',num2str(clockT(3)));
ClockTime=strcat(num2str(clockT(4)),':',num2str(clockT(5)),':',num2str(clockT(6)));

fprintf('Initializing...')
addpath(genpath(progDir))
fprintf('.Done\n');

%BIACSetupPsychtoolbox();
%run D:\Programs\MATLAB\PsychToolbox\3.0.11\BIACSetupPsychtoolbox.m
%name2save=answer{2};

%% Initialize timers

KbCheck;
WaitSecs(0.1);
GetSecs;
for randomizer=1:str2num(SubjectID)
    randi(47);
    rand(47);
end

warning('off','all');

%% Load trials from trialgenerator
[blockorder,learninglr] = iCount_trialgenerator_031915;

%% Open the Screen
AssertOpenGL;
KbName('UnifyKeyNames');

screens=Screen('Screens');
screenNumber=max(screens);
gray=GrayIndex(screenNumber);
lightgray= [220 220 220];
lightergray = [230 230 230];
white = [255 255 255];
[w, wRect]=Screen('OpenWindow',screenNumber, lightgray); %full screen ahead

[x,y] = RectCenter(wRect);
Screen('TextFont',w, 'Arial');
Screen('TextSize',w, 25);
Screen('TextStyle', w, 0);


%% Task
% fast or slow
if fast
    waitpoint5=.05;
    wait1=.1;
    wait1point5=.15;
    wait2=.2;
    wait3=.3;
    wait4=.4;
    wait5=.5;
    wait6=.6;
    wait16=1.6;
else
    waitpoint5=.5;
    wait1=1;
    wait2=2;
    wait3=3;
    wait1point5=1.5;
    wait4=4;
    wait5=5;
    wait6=6;
    wait16=16;
end
fixation='+';

% set outputs
clear output
output{1,1}='SubjNum';
output{1,2}='AgeGroup';
output{1,3}='ExperimenterName';
output{1,4}='RunNum';
output{1,5}='Date';
output{1,6}='Time';
output{1,7}='TrialNum';
output{1,8}='TrialNumbydomdist';
output{1,9}='Domain';
output{1,10}='Magnitude';
output{1,11}='CueOnLeft';
output{1,12}='CueOnRight';
output{1,13}='StockPic';
output{1,14}='BondPic';
output{1,15}='OptionChosen';
output{1,16}='FractalChosen';
output{1,17}='FracST';
output{1,18}='FracRT';
output{1,19}='StockValue';
output{1,20}='Face';
output{1,21}='FaceST';
output{1,22}='FaceRT';
output{1,23}='ProbGood';
output{1,24}='ProbST';
output{1,25}='ProbRT';
output{1,26}='Confidence';
output{1,27}='ConfidenceST';
output{1,28}='ConfidenceRT';
output{1,29}='StockNumber';
output{1,30}='BondNumber';
output{1,31}='GenderJudgment';
output{1,32}='TotalPayout';
output{1,33}='TrueProbGood';
output{1,34}='EstWithinRange?';

% outputs 1,2,3,5,6
for i = 1:72
    output{i+1,1}=SubjectID;
    output{i+1,2}=AgeGroup;
    output{i+1,3}=ExperimenterName;
    output{i+1,5}=date;
    output{i+1,6}=ClockTime;
end

% assign fractals to blocks, final fracassignvec will be a vector with the fractal number at each block position
fracassignvec = zeros(1,24);
for i=1:24
    fracassign = randi(24);
    while any(fracassign==fracassignvec)
        fracassign = randi(24);
    end
    fracassignvec(i) = fracassign;
end
sfracassignvec = fracassignvec(1:12);
bfracassignvec = fracassignvec(13:24);

% repeat process for faces
faceassignvec = zeros(1,72);
for i=1:72
    faceassign = randi(144);
    while any(faceassign==faceassignvec)
        faceassign = randi(144);
    end
    faceassignvec(i) = faceassign;
end

% assign a,b,c for stock fractals
for i=1:12
    a = rand(1);
    if a<.5
        sfracletassignvec{i}='a';
    else
        sfracletassignvec{i}='b';
    end
end

% assign a,b,c for bond fractals
for i=1:12
    a = rand(1);
    if a<.5
        bfracletassignvec{i}='a';
    else
        bfracletassignvec{i}='b';
    end
end

% Start display
usernum=1000+randi(8999);
user=['User',num2str(usernum),':'];
HideCursor();

% counter 1: count trials per dom / dist
counter1a=0;
counter1b=0;
counter1c=0;
counter1d=0;

% total payout
totpayout=0;

% instructions
for j=1:11
    instructions{j}=['Slide',num2str(j),'.tif'];
    I=instructions(j); I=I{1}(:,:); inst=imread(I); inst=imresize(inst, [2*x, 2*y]);
    instructions{j} = Screen('MakeTexture',w,inst);
end

for j=1:11
    HideCursor();
    Screen('DrawTexture', w, instructions{j}, [], [0 0 2*x 2*y]);
    Screen('Flip', w);
    resp=0;
    c=0;
    while ~strcmp(resp, 'space')
        [endrt, keyCode, deltaSecs]=KbWait([],2);
        resp=KbName(keyCode);
        c=c+1;
        if strcmp(resp, 'LeftArrow') || strcmp(resp, 'leftarrow')
            k=j-1;
            if k==0
                k=1;
            end
            Screen('DrawTexture', w, instructions{k}, [], [0 0 2*x 2*y]);
            Screen('Flip', w)
            while j~=k
                [endrt, keyCode, deltaSecs]=KbWait([],2);
                resp=KbName(keyCode);
                if strcmp(resp, 'RightArrow') || strcmp(resp, 'rightarrow')
                    k=k+1;
                    Screen('DrawTexture', w, instructions{k}, [], [0 0 2*x 2*y]);
                    Screen('Flip', w)
                elseif strcmp(resp, 'LeftArrow') || strcmp(resp, 'leftarrow')
                    k=k-1;
                    if k==0; k=1; end
                    Screen('DrawTexture', w, instructions{k}, [], [0 0 2*x 2*y]);
                    Screen('Flip',w);
                end
            end
        end
    end
end

for i=1:12
    
    % determine the fractal images to be used for this block
    balance = 0;
    stock = strcat(pwd,'\fractals\fractal',num2str(sfracassignvec(i)),sfracletassignvec{i},'.jpg');
    bond = strcat(pwd,'\fractals\fractal',num2str(bfracassignvec(i)),bfracletassignvec{i},'.jpg');
    for j=1:6
        output{(i-1)*6+j+1,29} = sfracassignvec(i);
        output{(i-1)*6+j+1,30} = bfracassignvec(i);
    end
    
    % interval between blocks
    Screen('TextSize',w,25);
    DrawFormattedText(w,'Ready!','center','center',[0 0 0]);
    Screen('Flip',w);
    WaitSecs(wait6);
    Screen('TextSize',w,25);
    DrawFormattedText(w,fixation,'center','center',[0 0 0]);
    Screen('Flip',w);
    WaitSecs(wait4);
    
    % block conditional features
    if blockorder(i)==0     % GAIN distribution, GOOD domain
        counter1a = counter1a+6;
        counter1 = counter1a;
        domain = 'Gain';
        for j=1
            instructions{j}=['Slide13.tif'];
            I=instructions(j); I=I{1}(:,:); inst=imread(I); inst=imresize(inst, [2*x, 2*y]);
            instructions{j} = Screen('MakeTexture',w,inst);
        end
        evgood = 0; ev = .367977;
        for j=1:6
            output{(i-1)*6+j+1,9}='GAIN';
            output{(i-1)*6+j+1,10}='high';
            bondvalue = 6;
            a = rand(1);
            if a<.7
                stockvalue(j) = 10;
                evgood = evgood+ev;
                output{(i-1)*6+j+1,33} = (10.^evgood)/(1+10.^evgood);
            else
                stockvalue(j) = 2;
                evgood = evgood-ev;
                output{(i-1)*6+j+1,33} = (10.^evgood)/(1+10.^evgood);
            end
        end
    elseif blockorder(i)==1 % GAIN distribution, BAD domain
        counter1b = counter1b+6;
        counter1 = counter1b;
        domain = 'Gain';
        for j=1
            instructions{j}=['Slide13.tif'];
            I=instructions(j); I=I{1}(:,:); inst=imread(I); inst=imresize(inst, [2*x, 2*y]);
            instructions{j} = Screen('MakeTexture',w,inst);
        end
        evgood = 0; ev = .367977;
        for j=1:6
            output{(i-1)*6+j+1,9}='GAIN';
            output{(i-1)*6+j+1,10}='low';
            bondvalue = 6;
            a = rand(1);
            if a<.3
                stockvalue(j) = 10;
                evgood = evgood+ev;
                output{(i-1)*6+j+1,33} = (10.^evgood)/(1+10.^evgood);
            else
                stockvalue(j) = 2;
                evgood = evgood-ev;
                output{(i-1)*6+j+1,33} = (10.^evgood)/(1+10.^evgood);
            end
        end
    elseif blockorder(i)==2 % LOSS distribution, GOOD domain
        counter1c = counter1c+6;
        counter1 = counter1c;
        domain = 'Loss';
        for j=1
            instructions{j}=['Slide12.tif'];
            I=instructions(j); I=I{1}(:,:); inst=imread(I); inst=imresize(inst, [2*x, 2*y]);
            instructions{j} = Screen('MakeTexture',w,inst);
        end
        evgood = 0; ev = .367977;
        for j=1:6
            output{(i-1)*6+j+1,9}='LOSS';
            output{(i-1)*6+j+1,10}='low';
            bondvalue = -6;
            a = rand(1);
            if a<.7
                stockvalue(j) = -2;
                evgood = evgood+ev;
                output{(i-1)*6+j+1,33} = (10.^evgood)/(1+10.^evgood);
            else
                stockvalue(j) = -10;
                evgood = evgood-ev;
                output{(i-1)*6+j+1,33} = (10.^evgood)/(1+10.^evgood);
            end
        end
    else                    % LOSS distribution, BAD domain
        counter1d = counter1d+6;
        counter1 = counter1d;
        domain = 'Loss';
        for j=1
            instructions{j}=['Slide12.tif'];
            I=instructions(j); I=I{1}(:,:); inst=imread(I); inst=imresize(inst, [2*x, 2*y]);
            instructions{j} = Screen('MakeTexture',w,inst);
        end
        evgood = 0; ev = .367977;
        for j=1:6
            output{(i-1)*6+j+1,9}='LOSS';
            output{(i-1)*6+j+1,10}='high';
            bondvalue = -6;
            a = rand(1);
            if a<.3
                stockvalue(j) = -2;
                evgood = evgood+ev;
                output{(i-1)*6+j+1,33} = (10.^evgood)/(1+10.^evgood);
            else
                stockvalue(j) = -10;
                evgood = evgood-ev;
                output{(i-1)*6+j+1,33} = (10.^evgood)/(1+10.^evgood);
            end
        end
    end
    
    % instructions
    for j=1
        HideCursor();
        Screen('DrawTexture', w, instructions{j}, [], [0 0 2*x 2*y]);
        Screen('Flip', w);
        resp=0;
        c=0;
        while ~strcmp(resp, 'space')
            [endrt, keyCode, deltaSecs]=KbWait([],2);
            resp=KbName(keyCode);
            c=c+1;
            if strcmp(resp, 'LeftArrow') || strcmp(resp, 'leftarrow')
                k=j-1;
                if k==0
                    k=1;
                end
                Screen('DrawTexture', w, instructions{k}, [], [0 0 2*x 2*y]);
                Screen('Flip', w)
                while j~=k
                    [endrt, keyCode, deltaSecs]=KbWait([],2);
                    resp=KbName(keyCode);
                    if strcmp(resp, 'RightArrow') || strcmp(resp, 'rightarrow')
                        k=k+1;
                        Screen('DrawTexture', w, instructions{k}, [], [0 0 2*x 2*y]);
                        Screen('Flip', w)
                    elseif strcmp(resp, 'LeftArrow') || strcmp(resp, 'leftarrow')
                        k=k-1;
                        if k==0; k=1; end
                        Screen('DrawTexture', w, instructions{k}, [], [0 0 2*x 2*y]);
                        Screen('Flip',w);
                    end
                end
            end
        end
    end
    
    % enter the block
    for j=1:6
        % slide 1
        output{(i-1)*6+j+1,4}=i;
        output{(i-1)*6+j+1,7}=j;
        output{(i-1)*6+j+1,8}=counter1-6+j;
        % determine position of stock and bond pt. 2,
        if learninglr((i-1)*6+j)==0 % 0 is stock on left
            lr = 0;
            img1 = imread(stock);
            img2 = imread(bond);
            DrawFormattedText(w,'Stock',x-200,y-130,[0 0 0]);
            DrawFormattedText(w,'Bond',x+150,y-130,[0 0 0]);
            if strcmp(domain,'Gain');
                DrawFormattedText(w,'Payoff: $2 or $10',x-280,y+130,[0 0 0]);
                DrawFormattedText(w,'Payoff: $6',x+80,y+130,[0 0 0]);
            else
                DrawFormattedText(w,'Payoff: -$2 or -$10',x-280,y+130,[0 0 0]);
                DrawFormattedText(w,'Payoff: -$6',x+80,y+130,[0 0 0]);
            end
            DrawFormattedText(w,'Press 1',x-280,y+160,[0 0 0]);
            DrawFormattedText(w,'Press 0',x+80,y+160,[0 0 0]);
            output{(i-1)*6+j+1,11}='s';
            output{(i-1)*6+j+1,12}='b';
            output{(i-1)*6+j+1,13}=stock;
            output{(i-1)*6+j+1,14}=bond;
        elseif learninglr((i-1)*6+j)==1
            lr = 1;
            img1 = imread(bond);
            img2 = imread(stock);
            DrawFormattedText(w,'Bond',x-200,y-130,[0 0 0]);
            DrawFormattedText(w,'Stock',x+150,y-130,[0 0 0]);
            if strcmp(domain,'Gain');
                DrawFormattedText(w,'Payoff: $6',x-280,y+130,[0 0 0]);
                DrawFormattedText(w,'Payoff: $2 or $10',x+80,y+130,[0 0 0]);
            else
                DrawFormattedText(w,'Payoff: -$6',x-280,y+130,[0 0 0]);
                DrawFormattedText(w,'Payoff: -$2 or -$10',x+80,y+130,[0 0 0]);
            end
            DrawFormattedText(w,'Press 1',x-280,y+160,[0 0 0]);
            DrawFormattedText(w,'Press 0',x+80,y+160,[0 0 0]);
            output{(i-1)*6+j+1,11}='b';
            output{(i-1)*6+j+1,12}='s';
            output{(i-1)*6+j+1,13}=stock;
            output{(i-1)*6+j+1,14}=bond;
        end
        DrawFormattedText(w,'Choose:','center',y-190,[0 0 0]);
        Screen('PutImage',w,img1,[x-280,y-100,x-80,y+100]);
        Screen('PutImage',w,img2,[x+80,y-100,x+280,y+100]);
        Screen('Flip',w);
        % time response
        timer1a = GetSecs;
        output{(i-1)*6+j+1,17}=timer1a;
        resp='0';
        subjresp=0;
        while strcmp(subjresp,'1')==0 && strcmp(subjresp,'0')==0
            timer1b = GetSecs;
            [keyIsDown,endrt,keyCode]=KbCheck;
            if keyIsDown
                resp=KbName(keyCode);
                subjresp=resp(1);
            end
        end
        output{(i-1)*6+j+1,18}=timer1b-timer1a;
        % determine response
        if strcmp(subjresp,'1')
            buttonpress = 'left';
            if lr==0
                output{(i-1)*6+j+1,15}='stock';
                output{(i-1)*6+j+1,16} = stock;
                balance = balance+stockvalue(j);
                totpayout = totpayout+stockvalue(j);
            elseif lr==1
                output{(i-1)*6+j+1,15}='bond';
                output{(i-1)*6+j+1,16} = bond;
                balance = balance+bondvalue;
                totpayout = totpayout+bondvalue;
            end
        elseif strcmp(subjresp,'0')
            buttonpress = 'right';
            if lr==0
                output{(i-1)*6+j+1,15}='bond';
                output{(i-1)*6+j+1,16} = bond;
                balance = balance+bondvalue;
                totpayout = totpayout+bondvalue;
            elseif lr==1
                output{(i-1)*6+j+1,15}='stock';
                output{(i-1)*6+j+1,16} = stock;
                balance = balance+stockvalue(j);
                totpayout = totpayout+stockvalue(j);
            end
        end
        output{(i-1)*6+j+1,19}=stockvalue(j);
        output{(i-1)*6+j+1,32}=totpayout;
        WaitSecs(wait1);
        
        % slide 2
        % choose and display face
        face = strcat('face',num2str(faceassignvec((i-1)*6+j)),'.png');
        facegender = facegendervec(faceassignvec((i-1)*6+j));
        output{(i-1)*6+j+1,20}=face;
        img3 = imread(face);
        Screen('PutImage',w,img3,[x-400,y,x-80,y+240]);
        DrawFormattedText_mod(w,'Choose:',x-300,y+250,[0 0 0],0);
        DrawFormattedText_mod(w,'M',x-355,y+280,[0 0 0],0);
        DrawFormattedText_mod(w,'F',x-135,y+280,[0 0 0],0);
        DrawFormattedText_mod(w,'Press 1',x-400,y+310,[0 0 0],-10);
        DrawFormattedText_mod(w,'Press 0',x-180,y+310,[0 0 0],-10);
        if stockvalue(j)==10
            valueimg = imread('outcome1.jpg');
        elseif stockvalue(j)==2
            valueimg = imread('outcome3.jpg');
        elseif stockvalue(j)==-2
            valueimg = imread('outcome4.jpg');
        elseif stockvalue(j)==-10
            valueimg = imread('outcome2.jpg');
        end
        Screen('PutImage',w,valueimg,[x+50,y-400,x+450,y-50]);
        Screen('Flip',w);
        timer2a = GetSecs;
        output{(i-1)*6+j+1,21}=timer2a;
        % determine response
        resp='0';
        subjresp=0;
        while strcmp(subjresp,'1')==0 && strcmp(subjresp,'0')==0
            timer2b = GetSecs;
            [keyIsDown,endrt,keyCode]=KbCheck;
            if keyIsDown
                resp=KbName(keyCode);
                subjresp=resp(1);
            end
        end
        output{(i-1)*6+j+1,22}=timer2b-timer2a;
        if facegender==str2num(subjresp)
            output{(i-1)*6+j+1,31}=1;
        else    
            output{(i-1)*6+j+1,31}=0;
        end
        
        % slide 3
        if totpayout>0
            message2 = strcat('$',num2str(totpayout));
        else
            message2 = strcat('-$',num2str(abs(totpayout)));
        end
        DrawFormattedText_mod(w,'Your payoff so far:','center',y-100,[0 0 0],0);
        DrawFormattedText_mod(w,message2,'center','center',[0 0 0],0);
        Screen('Flip',w);
        WaitSecs(wait2);
        
        % slide 4
        resp='';
        DrawFormattedText_mod(w,'Probability that this is a','center',y-100,[0 0 0],0);
        DrawFormattedText_mod(w,'good stock (0-100)','center',y-60,[0 0 0],0);
        DrawFormattedText_mod(w,'Type in a probability value and press [Enter]','center',y+100,[0 0 0],0);
        timer4a = GetSecs;
        resp=GetEchoString2(w,'Estimated probability: ',x-150,y+225,x,y,[],[],[],[],[],[],[]);
        timer4b = GetSecs;
        output{(i-1)*6+j+1,24}=timer4a;
        output{(i-1)*6+j+1,25}=timer4b-timer4a;
        Screen('Flip',w);
        output{(i-1)*6+j+1,23}=resp;
        
        % slide 5
        resp='';
        DrawFormattedText_mod(w,'How confident are you (1-9)','center',y-100,[0 0 0],0);
        DrawFormattedText_mod(w,'Type in a confidence value and press [Enter]','center',y+100,[0 0 0],0);
        timer5a = GetSecs;
        resp=GetEchoString3(w,'Confidence: ',x-150,y+225,x,y,[],[],[],[],[],[],[]);
        timer5b = GetSecs;
        output{(i-1)*6+j+1,27}=timer5a;
        output{(i-1)*6+j+1,28}=timer5b-timer5a;
        Screen('Flip',w);
        output{(i-1)*6+j+1,26}=resp;
    end
end

% Flag estimations-in-range for bonus calculation
for i=1:72
    if abs(str2num(output{i+1,23})-100*output{i+1,33})<=5
        output{i+1,34} = 1;
    else
        output{i+1,34} = 0;
    end
end

% count number of estimations-in-range
correst = sum(cell2mat(output(2:end,34)));
% $.10 per estimation-in-range
correstpay = .1*correst;
% $.10 per $1.00 in bank
final_balance = output{end,32};
pickpay = .1 * final_balance;

% sum bonus
totpayout = initpay+correstpay+pickpay;
if totpayout < (initpay - 5); % don't let the payout go below the minimum
    totpayout = (initpay - 5);
end


payoutmessage0 = strcat('accumulated earnings: $',num2str(final_balance));
DrawFormattedText(w,payoutmessage0,'center',y-200,[0 0 0]);

payoutmessage1 = strcat('$',num2str(initpay),'.00 initial payout');
DrawFormattedText(w,payoutmessage1,'center',y-50,[0 0 0]);

payoutmessage2 = strcat('+ $',num2str(pickpay),' for stock/bond choices (10% of accumulated earnings)');
DrawFormattedText(w,payoutmessage2,'center',y,[0 0 0]);

payoutmessage3 = strcat('+ $',num2str(correstpay),' for accuracy in estimating stock probability');
DrawFormattedText(w,payoutmessage3,'center',y+50,[0 0 0]);

payoutmessage4 = strcat('= $',num2str(totpayout),' total payout');
DrawFormattedText(w,payoutmessage4,'center',y+100,[0 0 0]);
Screen('Flip',w);

% output datafile
xlswrite(filename,output);

while ~strcmp(resp, 'q')
    ListenChar(2);
    [endrt, keyCode, deltaSecs]=KbWait([],2);
    resp=KbName(keyCode);
end
resp=''; ListenChar();

Screen('CloseAll');