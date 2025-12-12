% Actlumus data analysis
% Some light metrics based on Guidolin et al. "Protocol for a prospective, multicentre, 
% cross-sectional cohort study to assess personal light exposure." medRxiv (2024): 2024-02.

data_path = getpref('visualDiet','visualDietDataPath');
load([data_path '/pilotVDgrant'])

addpath '/Users/pattersonc/Documents/MATLAB/commonFx'

participants = unique(M.record_id);

T.LightHr = T.mEDI_min250*10;
M.LightHr = M.B10_250m*10;
SPL.LightHr = SPL.B10_250m*10;


%% Mixed effects models by day
mdl_melaAll = fitlme(T,'mEDI_min250~light_scale+(repeat|record_id)');


%% calculate 24-hr light shift

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

SPL.LightShift = M.LightShift(ismember(M.record_id,SPL.record_id));

T.SleepMidpoint_priorDay = circshift(T.SleepMidpoint,1);
T.SleepMidpoint_priorDay(1:7:end) = NaN;

T.light_scale_priorDay = circshift(T.light_scale,1);
T.light_scale_priorDay(1:7:end) = NaN;

T.LightHr_nextDay = circshift(T.LightHr,-1);
T.LightHr_nextDay(7:7:end) = NaN;

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
SPL.LightShiftVar = M.LightShiftVar(ismember(M.record_id,SPL.record_id));

%% Look at correlation between variables

[rLight, pLight] = corr([M.Ha M.vlsq8 M.fopqc M.pedmidas_score M.B10_500m M.mEDI M.B10_250m],'Type','Spearman');

Tcleaned = T(~isnan(T.MVPAdur5to10),:);
[rAll, pAll] = corr([Tcleaned.mEDI_min500 Tcleaned.mEDI Tcleaned.mEDI_min250 Tcleaned.MVPAdur5to10 Tcleaned.TST Tcleaned.WASO Tcleaned.SlEff]);

[rSl, pSl] = corr([SPL.sleepDis SPL.sleepImp SPL.B10_250m SPL.TST SPL.WASO SPL.SlEff SPL.sleepMidpoint SPL.MVPAdur5to10 SPL.vlsq8 SPL.fopqc],'Type','Spearman');

[rhoSl2, pSl2] = corr([SPL.B10_250m SPL.sleepDis SPL.sleepImp],'Type','Spearman');

%% calculate day-to-day predictions

fMdl = fitglm(T,'LightHr_nextDay ~ light_scale');

mdl_lightsleep = fitglme(T,'migraine ~ SleepMidpoint + LightShift + (1|record_id)');

figure
subplot(2,2,1)
plot(T.SleepMidpoint,T.LightShift,'ok')
lsline
ax = gca; ax.TickDir = 'out'; ax.Box = 'off';

subplot(2,2,2)
plot(T.SleepMidpoint,T.LightShift_nextDay,'ok')
lsline
ax = gca; ax.TickDir = 'out'; ax.Box = 'off';

subplot(2,2,3)
hold on
pp = unique(SPL.record_id);
mark = {'+k','+r','+b','+m','+c','xk','xr','xb','xm','*c','*k','*r','*b','*m','*c','.k','.r','.b','.m','.c'};
for x = 1:length(pp)
    plot(T.SleepMidpoint(T.record_id==pp(x)),T.LightShift(T.record_id==pp(x)),mark{:,x})
end
ax = gca; ax.TickDir = 'out'; ax.Box = 'off';

subplot(2,2,4)
hold on
for x = 1:length(pp)
    plot(T.SleepMidpoint(T.record_id==pp(x)),T.LightShift_nextDay(T.record_id==pp(x)),mark{:,x})
end
ax = gca; ax.TickDir = 'out'; ax.Box = 'off';

[coeff,score,latent,tsquared,explained,mu] = pca([T.WASO T.SlEff T.SleepMidpoint T.TST]);
T.pca1_sleep = score(:,1);
T.pca2_sleep = score(:,2);

T.SleepMidpointMin = T.SleepMidpoint.*60;
T.TSTmin = T.TST.*60;

% calculate sleep midpoint on weekends only
pSPL = unique(SPL.record_id);
for x = 1:length(pSPL)
    SleepMidpointWknd(x,1) = nanmean(T.SleepMidpoint(T.record_id==pSPL(x) & T.weekend_night==1));
end

SPL.SleepMidpointWknd = SleepMidpointWknd;

% plot sleep midpoint

figure
plot(ones(size(SPL.sleepMidpoint))+(rand(size(SPL.sleepMidpoint))-0.5).*0.05,SPL.sleepMidpoint,'ok','MarkerFaceColor',[0.5 0.5 0.5])
hold on
errorbar(1,mean(SPL.sleepMidpoint),std(SPL.sleepMidpoint),'ok')
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0.9 1.1];


% plot vlsq-8

figure
plot(ones(size(M.vlsq8))+(rand(size(M.vlsq8))-0.5).*0.05,M.vlsq8,'ok','MarkerFaceColor',[0.5 0.5 0.5])
hold on
errorbar(1,mean(M.vlsq8),std(M.vlsq8),'ok')
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0.9 1.1];

%% Compare and graph circadian metrics

[rSL, pSL] = corr([SPL.LightHr SPL.B10_500m SPL.LightShift SPL.TST SPL.WASO SPL.SlEff SPL.sleepMidpoint SPL.MVPAdur5to10]);

TS = T(~isnan(T.SleepMidpoint) & ~isnan(T.LightShift),:);
[rSL2, pSL2] = corr([TS.LightHr TS.mEDI_min500 TS.LightShift TS.TST TS.WASO TS.SlEff TS.SleepMidpoint TS.MVPAdur5to10]);


figure
plot_val = [TS.LightHr TS.LightShift TS.SleepMidpoint TS.MVPAdur5to10];
R = corr(plot_val);
ttl = {'Daylight >250 mEDI (hr)','Light shift (min)','Sleep midpoint (hr)','Physical activity'};
pl = 1;
for x = 1:4
    for y = 1:4
        subplot(4,4,pl)
        hold on
        plot(plot_val(:,x),plot_val(:,y),'.k','MarkerSize',8)
        lsline
        ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; xlabel(ttl(x)); ylabel(ttl(y)); title(num2str(R(x,y)))
        pl = pl+1;
    end
end