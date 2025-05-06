% Actlumus data analysis
% Some light metrics based on Guidolin et al. "Protocol for a prospective, multicentre, 
% cross-sectional cohort study to assess personal light exposure." medRxiv (2024): 2024-02.

data_path = getpref('visualDiet','visualDietDataPath');
load([data_path '/pilotVD'],'M','T','subject_data')

participants = unique(M.record_id);


%% Daytime, evening, night


figure
plot(ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.B10_250m,'ok','MarkerFaceColor','y')
hold on
plot(1,nanmean(M.B10_250m),'ys')

plot(2*ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.E3_10m,'ok','MarkerFaceColor','b')
plot(2,nanmean(M.E3_10m),'bs')

plot(3*ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.D6_1m,'ok','MarkerFaceColor','k')
plot(3,nanmean(M.D6_1m),'ks')



figure

plot(0.5*ones(size(M.CM(M.CM==0)))+0.1*(rand(length(M.CM(M.CM==0)),1)-0.25),M.mEDI_M(M.CM==0),'ok','MarkerFaceColor','c')
hold on
plot(0.5,mean(M.mEDI_M(M.CM==0)),'cs')

plot(1*ones(size(M.CM(M.CM==1)))+0.1*(rand(length(M.CM(M.CM==1)),1)-0.25),M.mEDI_M(M.CM==1),'ok','MarkerFaceColor','c')
hold on
plot(1,mean(M.mEDI_M(M.CM==1)),'cs')

plot(2*ones(size(M.CM(M.CM==0)))+0.1*(rand(length(M.CM(M.CM==0)),1)-0.25),M.mEDI_A(M.CM==0),'ok','MarkerFaceColor','c')
hold on
plot(2,mean(M.mEDI_A(M.CM==0)),'cs')

plot(2.5*ones(size(M.CM(M.CM==1)))+0.1*(rand(length(M.CM(M.CM==1)),1)-0.25),M.mEDI_A(M.CM==1),'ok','MarkerFaceColor','c')
hold on
plot(2.5,mean(M.mEDI_A(M.CM==1)),'cs')

plot(3.5*ones(size(M.CM(M.CM==0)))+0.1*(rand(length(M.CM(M.CM==0)),1)-0.25),M.mEDI_B(M.CM==0),'ok','MarkerFaceColor','c')
hold on
plot(3.5,nanmean(M.mEDI_B(M.CM==0)),'cs')

plot(4*ones(size(M.CM(M.CM==1)))+0.1*(rand(length(M.CM(M.CM==1)),1)-0.25),M.mEDI_B(M.CM==1),'ok','MarkerFaceColor','c')
hold on
plot(4,nanmean(M.mEDI_B(M.CM==1)),'cs')


ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 4.5]; ax.YLim = [log(0.01) log(100)];
ax.YTick = log([0.01 0.1 1 10 100 1000]); ax.YTickLabels = [0 0.1 1 10 100 1000];
title('Melanopic EDI by time of day')
xlabel('Time of Day')
ylabel('mEDI')

%% light intensity

figure
subplot(1,2,1)
plot(ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.Light,'ok','MarkerFaceColor','y')
hold on
plot(1,mean(M.Light),'bs')
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 2];
ax.YTick = 0:2000:16000; ax.YTickLabels = 0:2:16;
title('Total 24hr Illuminance')
xlabel('Participants')
ylabel('Illuminance exposure (klux*hr)')

subplot(1,2,2)
plot(ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.B10_1000m,'ok','MarkerFaceColor','y')
hold on
plot(1,mean(M.B10_1000m),'bs')
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 2];
title('Time of outdoor light exposure')
xlabel('Participants')
ylabel('Time >1000 lux (min)')


%% Look at correlation between variables

[rhoHF, pHF] = corr([M.age M.Ha M.BadHa M.pedmidas_score M.vlsq8 M.HaPrct M.MigPrct M.DisabilityPrct M.pain_scoreM M.light_scaleM],'type','Spearman');
[rHFC, pHFC] = corr([M.age M.Ha M.pedmidas_score M.vlsq8 M.fopqc]);
[rLight, pLight] = corr([M.age M.Ha M.vlsq8 M.pedmidas_score M.Light M.B10_1000m M.mEDI M.B10_250m M.E3_10m]);

%% Mixed effects models by day
mdl_photoAll = fitlme(T,'Light~ha+(repeat|record_id)');
mdl_melaAll = fitlme(T,'mEDI~disability+light_scale+ha+migraine+glasses_hr+(repeat|record_id)');
mdl_olAll = fitlme(T,'light_min1000~disability+light_scale+ha+migraine+glasses_hr+(repeat|record_id)');
mdl_bluedayAll = fitlme(T,'mEDI_min250~age+disability+light_scale+ha+migraine+glasses_hr+(repeat|record_id)');
mdl_blueeveningAll = fitlme(T,'mEDI_max10~age+disability+light_scale+ha+migraine+glasses_hr+(repeat|record_id)');

%% Regression models - visual diet predicting frequency, disability, and photophobia

% Aim 2
mdl_disablI = fitlm(M,'pedmidas_score~Light+B10_1000m');
mdl_HAfreqI = fitlm(M,'Ha~Light+B10_1000m');
mdl_BHAfreqI = fitlm(M,'BadHa~Light+B10_1000m');

% Aim 3
mdl_disablT = fitlm(M,'pedmidas_score~B10_250m+E3_10m+D6_1m');
mdl_fopT = fitlm(M,'fopqc~B10_250m+E3_10m+D6_1m');
mdl_HAfreqT = fitlm(M,'Ha~B10_250m+E3_10m+D6_1m');
mdl_BHAfreqT = fitlm(M,'BadHa~B10_250m+E3_10m+D6_1m');
mdl_CM = fitglm(M,'CM~B10_250m+E3_10m+D6_1m+Light+B10_1000m','Distribution','binomial');

%% Compare light levels on migraine days and non-migraine days
lb = 25;
ub = 975;

temp = subject_data.light_by_day;
tempM = subject_data.mEDI_by_day;
for x = 1:length(temp)
    temp2 = temp{1,x};
    tempM2 = tempM{1,x};
    xx = 1:1:1440;
    for y = 1:length(xx)-30
        for z = 1:size(temp2,2)
            temp3(z,y) = nanmean(temp2(xx(y):xx(y+29),z));
            tempM3(z,y) = nanmean(tempM2(xx(y):xx(y+29),z));
        end
    end
    if x == 1
        light_hrAll = temp3;
        mEDI_hrAll = tempM3;
    else
        light_hrAll = [light_hrAll;temp3];
        mEDI_hrAll = [mEDI_hrAll;tempM3];
    end
end
clear temp* 

for x = 1:length(participants)
    light_hrAllm(x,:) = nanmean(light_hrAll(T.record_id==participants(x),:));
    light_hrAllWDm(x,:) = nanmean(light_hrAll(T.record_id==participants(x) & T.weekend==0,:));
    light_hrAllWEm(x,:) = nanmean(light_hrAll(T.record_id==participants(x) & T.weekend==1,:));
    mEDI_hrAllm(x,:) = nanmean(mEDI_hrAll(T.record_id==participants(x),:));
    mEDI_hrAllWDm(x,:) = nanmean(mEDI_hrAll(T.record_id==participants(x) & T.weekend==0,:));
    mEDI_hrAllWEm(x,:) = nanmean(mEDI_hrAll(T.record_id==participants(x) & T.weekend==1,:));
end

figure
hold on
x_data = 1/60:1/60:(24-(30/60));
y_data = light_hrAllm(M.DisBi==0,:);
bootval=bootstrp(1000,@nanmean,y_data);
bootval=sort(bootval);
y_dataM=bootval(500,:);
y_dataERR1=bootval(lb,:);
y_dataERR2=bootval(ub,:);
x_ERR=cat(2,x_data,fliplr(x_data));
y_ERR=cat(2,y_dataERR1,fliplr(y_dataERR2));
TEMP = fill(x_ERR,y_ERR,[0.8 0.8 0.8],'EdgeColor','none');
plot(x_data,y_dataM,'-','Color','k')

y_data = light_hrAllm(M.DisBi==1,:);
bootval=bootstrp(1000,@nanmean,y_data);
bootval=sort(bootval);
y_dataM=bootval(500,:);
y_dataERR1=bootval(lb,:);
y_dataERR2=bootval(ub,:);
x_ERR=cat(2,x_data,fliplr(x_data));
y_ERR=cat(2,y_dataERR1,fliplr(y_dataERR2));
TEMP = fill(x_ERR,y_ERR,[1 0.8 0.8],'EdgeColor','none');
plot(x_data,y_dataM,'-','Color','r')

ax=gca; ax.TickDir='out'; ax.Box='off'; ax.XLim = [0,24]; ax.YLim = log([0.01,1200]);
ax.XTick = 0:6:23; ax.XTickLabels = {'12a','6a','12p','6p'};
ax.YTick = log([0.01 0.1 1 10 100 1000]); ax.YTickLabels = [0 0.1 1 10 100 1000];
ylabel('Light')
xlabel('Time (hrs)')
plot([0,6],log([1,1]),'--k')
plot([20,23],log([10,10]),'--k')
plot([7,17],log([250,250]),'--k')