% Organize actlumus validation dataset
data_path = getpref('visualDiet','visualDietDataPath');

Actlumus = {};
LightDiary = {};

for X = 1:4
    switch X
        case 1
            load([data_path '/Actlumus/Actlumus validation/actlumusValidationCPG.mat'])
        case 2
            load([data_path '/Actlumus/Actlumus validation/actlumusValidationBMP.mat'])
        case 3
            load([data_path '/Actlumus/Actlumus validation/actlumusValidationNRR.mat'])
        case 4
            load([data_path '/Actlumus/Actlumus validation/actlumusValidationCLS.mat'])
    end

    actlumus.IRphoto = actlumus.IR./actlumus.LIGHT;
    actlumus.tester = X*ones(height(actlumus),1);
    lightDiary.start_time = duration(string(lightDiary.start_time),'InputFormat','hh:mm');
    lightDiary.end_time = duration(string(lightDiary.end_time),'InputFormat','hh:mm');
    
    actlumus.MS = duration(string(actlumus.MS));
    
    % select actlumus data within the time window of light diary recordings
    actlumus = actlumus(actlumus.DATETIME<=max(lightDiary.date) & actlumus.DATETIME>=min(lightDiary.date),:);

    % convert light diary variables to numbers
    lightDiary.wear = zeros(height(lightDiary),1); % nonwear = 0
    lightDiary.wear(lightDiary.activity_type=='wear') = 1; % wear = 1
    lightDiary.wear(lightDiary.activity_type=='night' & lightDiary.night_act=="bedup") = -1; % night time = -1
    lightDiary.wear(lightDiary.activity_type=='night' & lightDiary.night_act=="beddown") = 0; % make face down night non-wear

    lightDiary.activity = NaN*ones(height(lightDiary),1); % 0 = nonwear still, 1 = nonwear mobile, 2 = sedentary, 3 = active, 4 = mixed, 5 = driving, 6 = sleep
    lightDiary.activity(lightDiary.nonwear_act=='drawer'|lightDiary.nonwear_act=='table') = 0;
    lightDiary.activity(lightDiary.nonwear_act=='bag') = 1;
    lightDiary.activity(lightDiary.wear_act=='sed') = 2;
    lightDiary.activity(lightDiary.wear_act=='active') = 3;
    lightDiary.activity(lightDiary.wear_act=='comb') = 4;
    lightDiary.activity(contains(lightDiary.describe,'driv')|contains(lightDiary.describe,'car')|contains(lightDiary.describe,'commut')) = 5;
    lightDiary.activity(lightDiary.wear==-1) = 6;
    
    lightDiary.environment = NaN*ones(height(lightDiary),1); % 0 = dark, 1 = indoor, 2 = mixed, 3 = outdoor
    lightDiary.environment(lightDiary.wear_light=="outdoor") = 3;
    lightDiary.environment(lightDiary.wear_light=="indoor") = 1;
    lightDiary.environment(lightDiary.wear_light=="both") = 2;
    lightDiary.environment(lightDiary.wear==-1) = 0;
    lightDiary.environment(lightDiary.nonwear_act=="drawer"|lightDiary.nonwear_act=="bag") = 0;
    lightDiary.environment(lightDiary.nonwear_act=="table") = 1;
    
    lightDiary.shirt = zeros(height(lightDiary),1); % 1 = covered by shirt
    lightDiary.shirt(lightDiary.wear_obstruct=="yes") = 1;
    
    lightDiary.beddown = zeros(height(lightDiary),1); % 1 = actlumus upsidedown on bedside table
    lightDiary.beddown(lightDiary.night_act=="beddown") = 1;

    
    % combine light diary with actlumus data
    actlumus.wear = NaN*ones(height(actlumus),1); % 0 = nonwear, 1 = wear, -1 = sleep
    actlumus.activity = NaN*ones(height(actlumus),1); % driving, active, sedentary, nonwear mobile, nonwear still
    actlumus.environment = NaN*ones(height(actlumus),1); % outdoor, indoor, dark
    actlumus.shirt = zeros(height(actlumus),1); % 0 no, 1 yes
    actlumus.beddown = zeros(height(actlumus),1); % 0 no, 1 yes

    
    for i = 1:height(lightDiary)
        sT = lightDiary.start_time(i); eT = lightDiary.end_time(i); D = lightDiary.date(i); W = lightDiary.wear(i);
        A = lightDiary.activity(i); E = lightDiary.environment(i); Sh = lightDiary.shirt(i); Bd = lightDiary.beddown(i);
    
        if sT<eT
            actlumus.wear(actlumus.DATETIME==D & actlumus.MS>=sT & actlumus.MS<eT) = W;
            actlumus.activity(actlumus.DATETIME==D & actlumus.MS>=sT & actlumus.MS<eT) = A;
            actlumus.environment(actlumus.DATETIME==D & actlumus.MS>=sT & actlumus.MS<eT) = E;
            actlumus.shirt(actlumus.DATETIME==D & actlumus.MS>=sT & actlumus.MS<eT) = Sh;
            actlumus.beddown(actlumus.DATETIME==D & actlumus.MS>=sT & actlumus.MS<eT) = Bd;
        else
            nD = lightDiary.date(i+1);
            actlumus.wear((actlumus.DATETIME==D & actlumus.MS>=sT)|(actlumus.DATETIME==nD & actlumus.MS<eT)) = W;
            actlumus.activity((actlumus.DATETIME==D & actlumus.MS>=sT)|(actlumus.DATETIME==nD & actlumus.MS<eT)) = A;
            actlumus.environment((actlumus.DATETIME==D & actlumus.MS>=sT)|(actlumus.DATETIME==nD & actlumus.MS<eT)) = E;
            actlumus.shirt((actlumus.DATETIME==D & actlumus.MS>=sT)|(actlumus.DATETIME==nD & actlumus.MS<eT)) = Sh;
            actlumus.beddown((actlumus.DATETIME==D & actlumus.MS>=sT)|(actlumus.DATETIME==nD & actlumus.MS<eT)) = Bd;
        end
    
    end

   % For CPG, add details about under shirt wear
   if X == 1
       actlumus.shirt(actlumus.DATETIME=='2025-08-08' & actlumus.MS>'07:14:00' & actlumus.MS<'07:22:00') = 1;
       actlumus.shirt(actlumus.DATETIME=='2025-08-09' & actlumus.MS>'05:21:00' & actlumus.MS<'05:25:00') = 1;
       actlumus.shirt(actlumus.DATETIME=='2025-08-09' & actlumus.MS>'08:53:00' & actlumus.MS<'08:57:00') = 1;
       actlumus.shirt(actlumus.DATETIME=='2025-08-12' & actlumus.MS>'13:47:00' & actlumus.MS<'13:53:00') = 1;
   end

    Actlumus(X) = {actlumus};
    LightDiary(X,:) = {lightDiary};

    if X == 1
        actlumusAll = actlumus;
    else
        actlumusAll = [actlumusAll;actlumus];
    end

end


%% identify test and validation data

cpg_dates = unique(actlumusAll.DATETIME(actlumusAll.tester==1));
cpg_testDates = cpg_dates([2:5 7:8]);

actlumusAll.testData = zeros(height(actlumusAll),1);
actlumusAll.testData(ismember(actlumusAll.DATETIME,cpg_testDates) & actlumusAll.tester==1) = 1;

%% build outcomes
[h,m,s] = hms(actlumusAll.MS);
actlumusAll.daytime = (h.*60) + m;
actlumusAll.daytimeBi = zeros(height(actlumusAll),1);
actlumusAll.daytimeBi(h>6 & h<22) = 1;
actlumusAll.wearLabel = categorical(actlumusAll.wear,-1:1:1,{'night','non-wear','wear'});

%% define cut-points

actlumusAll.indoor = zeros(height(actlumusAll),1);
actlumusAll.indoor(actlumusAll.LIGHT<442) = 1;
actlumusAll.hiIR = zeros(height(actlumusAll),1);
actlumusAll.hiIR(actlumusAll.IRphoto>0.0008) = 1;

actlumusAll.hang = zeros(height(actlumusAll),1);
actlumusAll.up = zeros(height(actlumusAll),1);
actlumusAll.down = zeros(height(actlumusAll),1);
actlumusAll.move = zeros(height(actlumusAll),1);
actlumusAll.dark = zeros(height(actlumusAll),1);

actlumusAll.wearBi = zeros(height(actlumusAll),1);
actlumusAll.wearBi(actlumusAll.wearLabel=='wear') = 1;
actlumusAll.wearBiLabel = categorical(actlumusAll.wearBi,[0,1],{'non-wear','wear'});

actlumusAll.nightBi = zeros(height(actlumusAll),1);
actlumusAll.nightBi(actlumusAll.wearLabel=='night') = 1;
actlumusAll.nightBiLabel = categorical(actlumusAll.nightBi,[0,1],{'non-night','night'});

% make lower temporal resolution version of actlumus data to determine wear
% vs. non-wear
bin_size = 0; % define binsize for cut-points
for x = floor((bin_size/2))+1:height(actlumusAll)-floor((bin_size/2))
    epoch = actlumusAll(x-floor((bin_size/2)):x+floor((bin_size/2)),:);

    if mode(epoch.ORIENTATION)<32
        actlumusAll.up(x) = 1;
    end

    if mode(epoch.ORIENTATION)==32
        actlumusAll.down(x) = 1;
    end

    if ~isempty(epoch.ORIENTATION(epoch.ORIENTATION==2))
        actlumusAll.hang(x) = 1;
    end

    if median(epoch.LIGHT)<=1
        actlumusAll.dark(x) = 1;
    end

    if mean(epoch.TAT)>0
        actlumusAll.move(x) = 1;
    end

end

save([data_path '/Actlumus/Actlumus validation/actlumusValidationAllbin1.mat'],'actlumusAll','Actlumus','LightDiary')