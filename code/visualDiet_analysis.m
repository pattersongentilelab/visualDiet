% Actlumus data analysis
% Some light metrics based on Guidolin et al. "Protocol for a prospective, multicentre, 
% cross-sectional cohort study to assess personal light exposure." medRxiv (2024): 2024-02.

data_path = getpref('visualDiet','visualDietDataPath');
load([data_path '/pilotVDwearRemoveBad'])

addpath '/Users/pattersonc/Documents/MATLAB/commonFx'

participants = unique(M.record_id);


%% Light Timing


figure
plot(ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.B10_250m,'ok','MarkerFaceColor','y')
hold on
plot(1,nanmean(M.B10_250m),'ys')

plot(2*ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.E3_10m,'ok','MarkerFaceColor','b')
plot(2,nanmean(M.E3_10m),'bs')

plot(3*ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.D6_1m,'ok','MarkerFaceColor','k')
plot(3,nanmean(M.D6_1m),'ks')

ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 4.5]; ax.YLim = [0 1.1];
title('Melanopic EDI by time of day')
xlabel('Time of Day')
ylabel('Time spent within recommended mEDI (%)')




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

 light_hrAllm = NaN*ones(length(participants),length(light_hrAll));
 light_hrAllWDm = NaN*ones(length(participants),length(light_hrAll));
 light_hrAllWEm = NaN*ones(length(participants),length(light_hrAll));
 mEDI_hrAllm = NaN*ones(length(participants),length(light_hrAll));
 mEDI_hrAllWDm = NaN*ones(length(participants),length(light_hrAll));
 mEDI_hrAllWEm = NaN*ones(length(participants),length(light_hrAll));

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
% y_data = mEDI_hrAllm(M.CM==0,:);
y_data = light_hrAll(T.GoodDay==1,:) - mEDI_hrAll(T.GoodDay==1,:);
bootval=bootstrp(1000,@nanmean,y_data);
bootval=sort(bootval);
y_dataM=bootval(500,:);
y_dataERR1=bootval(lb,:);
y_dataERR2=bootval(ub,:);
x_ERR=cat(2,x_data,fliplr(x_data));
y_ERR=cat(2,y_dataERR1,fliplr(y_dataERR2));
TEMP = fill(x_ERR,y_ERR,[0.8 0.8 0.8],'EdgeColor','none');
plot(x_data,y_dataM,'-','Color','k')

% y_data = mEDI_hrAllm(M.CM==1,:);
y_data = mEDI_hrAll(T.GoodDay==1,:);
bootval=bootstrp(1000,@nanmean,y_data);
bootval=sort(bootval);
y_dataM=bootval(500,:);
y_dataERR1=bootval(lb,:);
y_dataERR2=bootval(ub,:);
x_ERR=cat(2,x_data,fliplr(x_data));
y_ERR=cat(2,y_dataERR1,fliplr(y_dataERR2));
TEMP = fill(x_ERR,y_ERR,[1 0.8 0.8],'EdgeColor','none');
% plot(x_data,y_dataM,'-','Color','r')

ax=gca; ax.TickDir='out'; ax.Box='off'; ax.XLim = [0,24]; ax.YLim = log([0.01,1200]);
ax.XTick = 0:6:23; ax.XTickLabels = {'12a','6a','12p','6p'};
ax.YTick = log([0.01 0.1 1 10 100 1000]); ax.YTickLabels = [0 0.1 1 10 100 1000];
ylabel('Light')
xlabel('Time (hrs)')
plot([0,6],log([1,1]),'--k')
plot([20,23],log([10,10]),'--k')
plot([7,17],log([250,250]),'--k')

%% Climate and light comparison

mdl_climateLight = fitglme(T,'Light~1 + Precip + Temp + Daylight + (1|record_id)');
mdl_climate250min = fitglme(T,'mEDI_min250~1 + weekend + Precip + Temp + Daylight + (1|record_id)');
mdl_climateBL = fitglme(T,'light_min1000~1 + weekend + Precip + Temp + Daylight + (1|record_id)');
mdl_climateMig = fitglme(T,'migraine~1 + weekend + Precip + Temp + Daylight + (1|record_id)','Distribution','Binomial');
mdl_climateHA = fitglme(T,'ha~1 + weekend + Precip + Temp + Daylight + (1|record_id)','Distribution','Binomial');

mdl_climatePain = fitglme(T,'pain_score~1 + weekend + Precip + Temp + Daylight + (1|record_id)','Distribution','Poisson');

mdl_climateLightSens = fitglme(T,'light_scale~1 + weekend + Precip + Temp + Daylight + Light + (1|record_id)','Distribution','Poisson');

%% Calculate shifts in 24-hr light cycle

allm = nanmean(mEDI_hrAll,1);
PP = -200:200;
for ii = 1:length(participants)
    I = nanmean(mEDI_hrAll(T.record_id==participants(ii),:),1);

    for pp = PP
        cr(pp+max(PP)+1) = corr(allm',circshift(I',pp)); 
    end
    [~,idx] = max(cr);
    shiftVal(ii,:) = PP(idx);
    fitVal(ii,:) = corr(allm',circshift(I',shiftVal));

    % figure(100)
    % hold on
    % plot(x_data,allm,'-k')
    % hold on
    % plot(x_data,I,'--b')
    % plot(x_data,circshift(I',shiftVal(ii,:)),'--r')
    % pause
    % clf
end

M.LightShift = shiftVal.*-1;
M.LightShiftFit = fitVal;

for ii = 1:height(T)
    I = mEDI_hrAll(ii,:);

    for pp = PP
        cr(pp+max(PP)+1) = corr(allm',circshift(I',pp)); 
    end
    [~,idx] = max(cr);
    shiftVal_day(ii,:) = PP(idx);
    fitVal_day(ii,:) = corr(allm',circshift(I',shiftVal));
end

T.LightShift = shiftVal_day.*-1;
T.LightShiftFit = fitVal_day;
T.LightShift(T.LightShiftFit<0.5) = NaN;


T.LightShift_nextDay = circshift(T.LightShift,-1);
T.LightShift_nextDay(7:7:end) = NaN;

T.migraine_nextDay = circshift(T.migraine,-1);
T.migraine_nextDay(7:7:end) = NaN;
T.ha_nextDay = circshift(T.ha,-1);
T.ha_nextDay(7:7:end) = NaN;

T.weekend_night = zeros(height(T.migraine),1);
T.weekend_night(T.daynum==7|T.daynum==6) = 1;

% add variance
for i = 1:length(participants)
    LightShiftVar(i,:) = nanvar(T.LightShift(T.record_id==participants(i)));
end

M.LightShiftVar = LightShiftVar;

% Plot light shift as a function of migraine and headache days

figure
subplot(2,1,1)
plot(M.LightShift,M.Ha,'ok','MarkerFaceColor','k')
hold on
lsline
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.YLim = [0 31]; ax.XLim = [-200,200];
xlabel('Headache days per month')
ylabel('Light Shift')
[r,p] = corr(M.LightShift,M.Ha,'Type','Spearman');
title(['r = ' num2str(r) ', p = ' num2str(p)])

subplot(2,1,2)
plot(M.LightShift,M.BadHa,'ok','MarkerFaceColor','k')
hold on
lsline
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.YLim = [0 31]; ax.XLim = [-200,200];
xlabel('Bad headache days per month')
ylabel('Light Shift')
[r,p] = corr(M.LightShift,M.BadHa,'Type','Spearman');
title(['r = ' num2str(r) ', p = ' num2str(p)])
