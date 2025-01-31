% Actlumus data analysis
% Some light metrics based on Guidolin et al. "Protocol for a prospective, multicentre, 
% cross-sectional cohort study to assess personal light exposure." medRxiv (2024): 2024-02.

data_path = getpref('visualDiet','visualDietDataPath');

load([data_path 'VDS.mat'])
load([data_path 'surveyData.mat'])

participants = fieldnames(headache_diary);

actlumus = struct2cell(actlumus);
headache_diary = struct2cell(headache_diary);

bad_trials = [zeros(1,7);zeros(1,7);zeros(1,7);zeros(1,7);[0 0 0 0 0 0 1];...
    zeros(1,7);zeros(1,7);zeros(1,7);zeros(1,7);zeros(1,7)];

figure
for i = 1:length(participants)
    vd = actlumus{i};
    hd = headache_diary{i};

    % Select actlumus data only on days that had a corresponding headache diary
    vd.month = month(vd.DATE); vd.day = day(vd.DATE); vd.year = year(vd.DATE);% fix day/month switch
    hd.month = month(hd.datetime_headache_diary); hd.day = day(hd.datetime_headache_diary); hd.year = year(hd.datetime_headache_diary); % fix day/month switch
    hd.repeat = hd.redcap_repeat_instance;
    vd.hour = hour(vd.TIME);
    vd.min = minute(vd.TIME);


    % correct days where the headache diary was filled out the following day
    Day = unique(hd.day);
    if length(hd.day)>length(Day)
        for j = 1:length(Day)
            temp = find(hd.day==Day(j));
            if length(temp)>1
                hd.day(temp(1)) = hd.day(temp(1))-1;
            end
            clear temp
        end
    end
    Day = unique(hd.day);
    
    vd_cleaned = vd(ismember(vd.day,hd.day),:);

    % Combine headache diary with actlumus mean metrics, calculating mean luminance
    % data over each hour by day
    t = hd(:,1);
    t.repeat = hd.repeat;
    t.month = hd.month;
    t.day = hd.day;
    t.year = hd.year;
    t.ha = hd.headache_today;
    t.migraine = hd.migraine_today_self_report;
    t.pain_score = hd.pain_score_today_nrs;
    t.pain_score(isnan(t.pain_score)) = 0;
    t.ha_start = hd.ha_start;
    t.ha_hr = hd.ha_hr;
    t.light_scale = hd.light_scale;
    t.disability = hd.disability_today;
    t.ha_rescue = hd.rescue_meds_used_today;
    if iscell(hd.glasses_hr)
        hd.glasses_hr = NaN*ones(height(hd),1);
    end
    t.glasses_hr = hd.glasses_hr;
    t.light_device = hd.light_device;
    t.actv_device = hd.actv_device;
    t.hd_comp = hd.headache_diary_complete;
    
    t.migraine(t.ha==0) = 0;
    t.disability(t.ha==0) = 0;
    t.ha_hr(t.ha==0) = 0;
    
    Hours = 0:1:23;
    Light_hr = NaN*ones(length(Day),length(Hours));
    mEDI_hr = NaN*ones(length(Day),length(Hours));
    Min250_B10 = NaN*ones(length(Day),1);
    Min1000_B10l = NaN*ones(length(Day),1);
    Max10_E3 = NaN*ones(length(Day),1);
    Max1_D6 = NaN*ones(length(Day),1);
    Light = NaN*ones(length(Day),1);
    mEDI = NaN*ones(length(Day),1);

    for d = 1:length(Day)
        % remove data from days where the device was removed, or there
        % is incomplete data for the day
        if bad_trials(i,d)==0
            for h = 1:24
                Light_hr(d,h) = nanmedian(vd_cleaned.LIGHT(vd_cleaned.day==Day(d) & vd_cleaned.hour==Hours(h))); % photopic light
                mEDI_hr(d,h) = nanmedian(vd_cleaned.MELANOPICEDI(vd_cleaned.day==Day(d) & vd_cleaned.hour==Hours(h)));
            end
            Light(d,1) = sum(vd_cleaned.LIGHT(vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.LIGHT)))./60; % calculate lux*hr
            mEDI(d,1) = sum(vd_cleaned.MELANOPICEDI(vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.LIGHT)))./60; % calculate lux*hr
            % time period of certain light exposures
            Min250_B10(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.MELANOPICEDI>250 & vd_cleaned.day==Day(d) & vd_cleaned.hour>=7 & vd_cleaned.hour<17))./(10*60);
            Min1000_B10l(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.LIGHT>1000 & vd_cleaned.day==Day(d)));
            Max10_E3(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.MELANOPICEDI<10 & vd_cleaned.day==Day(d) & vd_cleaned.hour>=20 & vd_cleaned.hour<23))./(3*60);
            Max1_D6(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.MELANOPICEDI<1 & vd_cleaned.day==Day(d) & vd_cleaned.hour<6))./(6*60);
           
            clear temp*
        end
    end
    % restructure actlumus data by day
    light_by_day = reshape(vd_cleaned.LIGHT,[1440,7]);
    mEDI_by_day = reshape(vd_cleaned.MELANOPICEDI,[1440,7]);
    
    t.Light = Light;
    t.mEDI = mEDI;
    t.mEDI_min250 = Min250_B10;
    t.light_min1000 = Min1000_B10l;
    t.mEDI_max10 = Max10_E3;
    t.mEDI_max1 = Max1_D6;
    
    subject_data.summary{:,i} = t;
    subject_data.light_hr{:,i} = Light_hr;
    subject_data.light_by_day{:,i} = light_by_day;
    subject_data.mEDI_hr{:,i} = mEDI_hr;
    subject_data.mEDI_by_day{:,i} = mEDI_by_day;
    
    
    subplot(length(participants),1,i)
    hold on
    x = 0:0.01667:24;
    

    for X = 1:length(Day)
        y = light_by_day(:,X);
        y(y==0) = 0.001;
        y = log(y);
        y2 = mEDI_by_day(:,X);
        y2(y2==0) = 0.001;
        y2 = log(y2);
        if bad_trials(i,X)==0
            c1 = [0.5 0.5 0];
            c2 = [0.8 0.8 1];
        else
            c1 = [0.5 0.5 0.5];
            c2 = [0.2 0.2 0.2];
        end
        fill([7+(24*(X-1)) 7+(24*(X-1)) 17+(24*(X-1)) 17+(24*(X-1))],log([0.001 100000 100000 0.001]),[1 1 0.8])
        hold on
        fill([20+(24*(X-1)) 20+(24*(X-1)) 23+(24*(X-1)) 23+(24*(X-1))],log([0.001 100000 100000 0.001]),[0.8 0.8 1])
        fill([0+(24*(X-1)) 0+(24*(X-1)) 6+(24*(X-1)) 6+(24*(X-1))],log([0.001 100000 100000 0.001]),[0.8 0.8 0.8])
        plot(x,y,'Color',c1)
        plot(x,y2,'Color',c2)
        plot([x(end) x(end)],[0.1 log(120000)],'--','Color',[0.5 0.5 0.5])
        ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 24*7];
        ax.YLim = [log(0.009) log(120000)]; ax.YTick = log([0.1 1 10 100 1000 10000 100000]); ax.YTickLabels = {'0','1','10','100','1,000','10,000','100,000'}; ax.XTick = 24:24:24*7; 
        ax.XTickLabels = {'day 1','day 2','day 3','day 4','day 5','day 6','day 7'};
        if i == 1
            title(['Light Exposure Day ' num2str(X)])
        end
        if i == length(participants)
            xlabel('Time (hours)')
            ylabel('Luminance (loglux)')
        end      
        x = x+24;
    end
    
    clear B10* Min250* Min1000* Max10* Max1* 
    
    
    
    if i==1
        T = subject_data.summary{1,1};
    else
        T = [T;subject_data.summary{1,i}];
    end
end


participants = unique(T.record_id);


% pre-allocate
HaPrct = NaN*ones(length(participants),1); DisabilityPrct = NaN*ones(length(participants),1);
MigPrct = NaN*ones(length(participants),1); 
pain_scoreM = NaN*ones(length(participants),1); light_scaleM = NaN*ones(length(participants),1);
Light = NaN*ones(length(participants),1);
mEDI = NaN*ones(length(participants),1);
B10_250m = NaN*ones(length(participants),1); B10_1000m = NaN*ones(length(participants),1);
E3_10m = NaN*ones(length(participants),1); D6_1m = NaN*ones(length(participants),1);
HAhrM = NaN*ones(length(participants),1);

for i = 1:length(participants)
    HaPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.ha==1))./length(T.record_id(T.record_id==participants(i)));
    MigPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.migraine==1))./length(T.record_id(T.record_id==participants(i)));
    DisabilityPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.disability==1))./length(T.record_id(T.record_id==participants(i)));
    boot2 = bootstrp(1000,@median,T.pain_score(T.record_id==participants(i)));
    pain_scoreM(i,:) = prctile(boot2,50);
    boot3 = bootstrp(1000,@median,T.light_scale(T.record_id==participants(i)));
    light_scaleM(i,:) = prctile(boot3,50);
    Light(i,:) = nanmedian(T.Light(T.record_id==participants(i)));
    mEDI(i,:) = nanmedian(T.mEDI(T.record_id==participants(i)));
    B10_250m(i,:) = nanmedian(T.mEDI_min250(T.record_id==participants(i)));
    B10_1000m(i,:) = nanmedian(T.light_min1000(T.record_id==participants(i)));
    E3_10m(i,:) = nanmedian(T.mEDI_max10(T.record_id==participants(i)));
    D6_1m(i,:) = nanmedian(T.mEDI_max1(T.record_id==participants(i)));

    HAhrM(i,:) = nanmedian(T.ha_hr(T.record_id==participants(i)));
    clear boot*
end

M = table(participants,'VariableNames',{'record_id'});

% Add additional info from survey data
surveys = surveys(ismember(surveys.record_id,M.record_id),:);
M.sex = surveys.patient_sex(surveys.redcap_event_name=='visit_1_arm_1');
M.age = surveys.patient_age_today(surveys.redcap_event_name=='visit_1_arm_1');
M.Ha = surveys.days_any_ha(surveys.redcap_event_name=='visit_2_arm_1');
M.BadHa = surveys.days_bad_ha(surveys.redcap_event_name=='visit_2_arm_1');
M.pedmidas_score = surveys.pedmidas_score(surveys.redcap_event_name=='visit_3_arm_1');
M.light_scaleOverall = surveys.sensitivity_score(surveys.redcap_event_name=='visit_2_arm_1');
M.light_averse = surveys.score_light(surveys.redcap_event_name=='visit_2_arm_1');
M.light_worse = surveys.score_worse(surveys.redcap_event_name=='visit_2_arm_1');
M.light_avoid = surveys.score_avoid(surveys.redcap_event_name=='visit_2_arm_1');
M.light_score = sum([M.light_averse M.light_worse M.light_avoid],2);
M.pain_fear = surveys.fear_score(surveys.redcap_event_name=='visit_2_arm_1');
M.pain_avoid = surveys.avoid_score(surveys.redcap_event_name=='visit_2_arm_1');
M.fopqc = surveys.fopqc_score(surveys.redcap_event_name=='visit_2_arm_1');

% add headache features
M.HaPrct = HaPrct; M.MigPrct = MigPrct; M.DisabilityPrct = DisabilityPrct;
M.pain_scoreM = pain_scoreM; M.light_scaleM = light_scaleM; M.HAhrM = HAhrM;

% add light measurements
M.Light = Light; M.mEDI = mEDI; M.B10_1000m = B10_1000m; M.B10_250m = B10_250m;
M.E3_10m = E3_10m; M.D6_1m = D6_1m;
clear lightM light_scaleM pain_scoreM *Lo *Hi *Prct boot* mEDImin* LightVar B10* D6* E3*

% add factors to T
T.fopqc = NaN*ones(height(T),1);
T.pedmidas = NaN*ones(height(T),1);
T.age = NaN*ones(height(T),1);

for i = 1:length(participants)
    T.fopqc(T.record_id==participants(i)) = M.fopqc(i);
    T.pedmidas(T.record_id==participants(i)) = M.pedmidas_score(i);
    T.age(T.record_id==participants(i)) = M.age(i);
end

%% Daytime, evening, night


figure
plot(ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.B10_250m,'ok','MarkerFaceColor','y')
hold on
plot(1,nanmean(M.B10_250m),'ys')

plot(2*ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.E3_10m,'ok','MarkerFaceColor','b')
plot(2,nanmean(M.E3_10m),'bs')

plot(3*ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.D6_1m,'ok','MarkerFaceColor','k')
plot(3,nanmean(M.D6_1m),'ks')

ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 4]; ax.YLim = [0 1];
title('Melanopic EDI by time of day')
xlabel('Time of Day')
ylabel('Proportion of time wih recommended Melanopic EDI levels')

%% light intensity

figure
subplot(1,3,1)
plot(ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.Light,'ok','MarkerFaceColor','y')
hold on
plot(1,nanmean(M.Light),'bs')
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 2];
title('Total 24hr Illuminance')
xlabel('Participants')
ylabel('Illuminance exposure (lux*hr)')

subplot(1,3,2)
plot(ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.B10_1000m,'ok','MarkerFaceColor','y')
hold on
plot(1,nanmean(M.B10_1000m),'bs')
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 2];
title('Time of outdoor light exposure')
xlabel('Participants')
ylabel('Time >1000 lux (min)')

% light intensity
subplot(1,3,3)
plot(M.light_score,M.Light,'ok','MarkerFaceColor','y')
lsline
ax = gca; ax.TickDir = 'out'; ax.Box = 'off';
xlabel('light sensitivity and avoidance score')
ylabel('Photopic illuminance')

%% HA burden with light metrics




% evening light
figure
subplot(1,3,1)
plot(M.Ha,M.E3_10m,'ok','MarkerFaceColor','w')
lsline
ax = gca; ax.TickDir = 'out'; ax.Box = 'off';
xlabel('No. Headache days/month')
ylabel('Proportion of evening time <10 lux mEDI')

subplot(1,3,2)
plot(M.pedmidas_score,M.E3_10m,'ok','MarkerFaceColor','w')
lsline
ax = gca; ax.TickDir = 'out'; ax.Box = 'off';
xlabel('PedMIDAS score')
ylabel('Proportion of evening time <10 lux mEDI')

subplot(1,3,3)
plot(M.light_score,M.E3_10m,'ok','MarkerFaceColor','w')
lsline
ax = gca; ax.TickDir = 'out'; ax.Box = 'off';
xlabel('Light Sensitivity and Avoidance score')
ylabel('Proportion of evening time <10 lux mEDI')


%% Look at correlation between variables

[rhoHF, pHF] = corr([M.age M.Ha M.BadHa M.pedmidas_score M.light_scaleOverall M.light_score M.HaPrct M.MigPrct M.DisabilityPrct M.pain_scoreM M.light_scaleM],'type','Spearman');
[rHFC, pHFC] = corr([M.age M.Ha M.pedmidas_score M.light_scaleOverall M.fopqc]);
[rLight, pLight] = corr([M.age M.Ha M.light_score M.pedmidas_score M.Light M.B10_1000m M.mEDI M.B10_250m M.E3_10m]);

%% Mixed effects models by day
mdl_photoAll = fitlme(T,'Light~disability+light_scale+ha+migraine+(repeat|record_id)');
mdl_melaAll = fitlme(T,'mEDI~disability+light_scale+ha+migraine+(repeat|record_id)');
mdl_olAll = fitlme(T,'light_min1000~disability+light_scale+ha+migraine+(repeat|record_id)');
mdl_bluedayAll = fitlme(T,'mEDI_min250~disability+light_scale+ha+migraine+(repeat|record_id)');
mdl_blueeveningAll = fitlme(T,'mEDI_max10~disability+light_scale+ha+migraine+(repeat|record_id)');

%% Regression models - visual diet predicting frequency, disability, and photophobia

% Aim 2
mdl_disablI = fitlm(M,'pedmidas_score~Light+mEDI');
mdl_photophobiaI = fitlm(M,'light_score~Light+mEDI');
mdl_HAfreqI = fitlm(M,'Ha~Light+mEDI');

% Aim 3
mdl_disablT = fitlm(M,'pedmidas_score~B10_250m+E3_10m+D6_1m');
mdl_photophobiaT = fitlm(M,'light_scaleOverall~B10_250m+E3_10m+D6_1m');
mdl_HAfreqT = fitlm(M,'Ha~Light+B10_1000m+B10_250m+E3_10m+D6_1m');
mdl_BHAfreqT = fitlm(M,'BadHa~Light+B10_1000m+B10_250m+E3_10m+D6_1m');