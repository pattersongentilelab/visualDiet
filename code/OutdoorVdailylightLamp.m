% Compare light exposure with outdoor light vs. daylight lamp
data_path = getpref('visualDiet','visualDietDataPath');

load('/Users/pattersonc/Library/CloudStorage/OneDrive-Children''sHospitalofPhiladelphia/Research/Visual Diet/Data/Actlumus/Daylight v Outdoor/CPG_daylightLampOutdoor030625.mat')


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
    A = lightDiary.activity(i); E = lightDiary.environment(i); LE = lightDiary.lightExp(i);

    if sT<eT
        actlumus.wear(actlumus.DATETIME==D & actlumus.MS>=sT & actlumus.MS<eT) = W;
        actlumus.activity(actlumus.DATETIME==D & actlumus.MS>=sT & actlumus.MS<eT) = A;
        actlumus.environment(actlumus.DATETIME==D & actlumus.MS>=sT & actlumus.MS<eT) = E;
        actlumus.lightexp(actlumus.DATETIME==D & actlumus.MS>=sT & actlumus.MS<eT) = LE;
    else
        nD = lightDiary.date(i+1);
        actlumus.wear((actlumus.DATETIME==D & actlumus.MS>=sT)|(actlumus.DATETIME==nD & actlumus.MS<eT)) = W;
        actlumus.activity((actlumus.DATETIME==D & actlumus.MS>=sT)|(actlumus.DATETIME==nD & actlumus.MS<eT)) = A;
        actlumus.environment((actlumus.DATETIME==D & actlumus.MS>=sT)|(actlumus.DATETIME==nD & actlumus.MS<eT)) = E;
        actlumus.lightexp((actlumus.DATETIME==D & actlumus.MS>=sT)|(actlumus.DATETIME==nD & actlumus.MS<eT)) = LE;
    end

end

actlumus.logmEDI = actlumus.MELANOPICEDI;
actlumus.logmEDI(actlumus.logmEDI==0) = 0.1;
actlumus.logmEDI = log(actlumus.logmEDI);

figure
Udates = unique(actlumus.DATETIME);
for x = 1:length(Udates)
    subplot(7,2,x)
    plot(actlumus.MS(actlumus.DATETIME==Udates(x)),actlumus.logmEDI(actlumus.DATETIME==Udates(x)),'-b')
    hold on
    plot(actlumus.MS(actlumus.DATETIME==Udates(x) & actlumus.lightexp=='outdoor'),actlumus.logmEDI(actlumus.DATETIME==Udates(x) & actlumus.lightexp=='outdoor'),'.c')
    plot(actlumus.MS(actlumus.DATETIME==Udates(x) & actlumus.lightexp=='daylight lamp'),actlumus.logmEDI(actlumus.DATETIME==Udates(x) & actlumus.lightexp=='daylight lamp'),'.y')
    ax = gca; ax.Box = 'off'; ax.TickDir = 'out'; ax.YTick = log([0.01 0.1 1 10 100 1000 10000]); ax.YTickLabels = [0 0.1 1 10 100 1000 10000];
end

%% calculate klux*hr of daylight lamp vs. outdoor light morning exposure

LightMorning = actlumus(actlumus.MS>={'06:00:00'} & actlumus.MS<{'8:00:00'},:);

MorningSum = table(Udates);
MorningSum.Outdoor = zeros(length(Udates),1);
MorningSum.Lamp = zeros(length(Udates),1);

figure
hold on
plot(actlumus.MS(actlumus.lightexp=='indoor' & actlumus.wear==1 & actlumus.shirt==0),actlumus.logmEDI(actlumus.lightexp=='indoor' & actlumus.wear==1 & actlumus.shirt==0),'ok','MarkerFaceColor',[0.5 0.5 0.5])
plot(actlumus.MS(actlumus.lightexp=='outdoor' & actlumus.wear==1 & actlumus.shirt==0),actlumus.logmEDI(actlumus.lightexp=='outdoor' & actlumus.wear==1 & actlumus.shirt==0),'ok','MarkerFaceColor','c')
plot(actlumus.MS(actlumus.lightexp=='daylight lamp' & actlumus.wear==1 & actlumus.shirt==0),actlumus.logmEDI(actlumus.lightexp=='daylight lamp' & actlumus.wear==1 & actlumus.shirt==0),'ok','MarkerFaceColor','y')
ax = gca; ax.Box = 'off'; ax.TickDir = 'out'; ax.YTick = log([10 100 1000 10000 100000 1000000]); ax.YTickLabels = [0 0.1 1 10 100 1000 10000 100000 1000000];

for x = 1:length(Udates)
    Klux(x,:) = sum(LightMorning.MELANOPICEDI(LightMorning.DATETIME==Udates(x)))./2;
    temp = string(LightMorning.lightexp(LightMorning.DATETIME==Udates(x)));
    if max(contains(temp,'outdoor'))==1
        MorningSum.Outdoor(x) = 1;
    end

    if max(contains(temp,'daylight lamp'))==1
        MorningSum.Lamp(x) = 1;
    end
end

MorningSum.Klux = Klux;

MorningSum.Condition = zeros(length(Udates),1);
MorningSum.Condition(MorningSum.Outdoor==0 & MorningSum.Lamp==1) = 1;
MorningSum.Condition(MorningSum.Outdoor==1 & MorningSum.Lamp==0) = 2;
MorningSum.Condition(MorningSum.Outdoor==1 & MorningSum.Lamp==1) = 3;
MorningSum.ConditionCat = categorical(MorningSum.Condition,[0 1 2 3],{'none','lamp','outdoor','both'});

figure
plot(MorningSum.Condition,MorningSum.Klux,'ok','MarkerFaceColor','c')
hold on
plot(0,geomean(MorningSum.Klux(MorningSum.Condition==0)),'sk')
plot(1,geomean(MorningSum.Klux(MorningSum.Condition==1)),'sk')
plot(2,geomean(MorningSum.Klux(MorningSum.Condition==2)),'sk')
ax = gca; ax.Box = 'off'; ax.TickDir = 'out'; ax.XLim = [-0.5 3.5]; ax.XTick = 0:1:3; ax.XTickLabels = {'none','lamp','outdoor','both'}; ax.YScale = 'log'; ax.YLim = [500 100000];

figure
subplot(2,1,1)
plot(actlumus.logmEDI(actlumus.lightexp=='daylight lamp'),'sk','MarkerFaceColor','y')
ax = gca; ax.Box = 'off'; ax.TickDir = 'out'; ax.YTick = log([0 0.1 1 10 100 1000 10000]); ax.YTickLabels = [0 0.1 1 10 100 1000 10000];

subplot(2,1,2)
plot(actlumus.logmEDI(actlumus.lightexp=='outdoor'),'sk','MarkerFaceColor','c')
ax = gca; ax.Box = 'off'; ax.TickDir = 'out'; ax.YTick = log([0 0.1 1 10 100 1000 10000]); ax.YTickLabels = [0 0.1 1 10 100 1000 10000];
