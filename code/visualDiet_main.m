% Actlumus data analysis
% Some light metrics based on Guidolin et al. "Protocol for a prospective, multicentre, 
% cross-sectional cohort study to assess personal light exposure." medRxiv (2024): 2024-02.

data_path = getpref('visualDiet','visualDietDataPath');

load([data_path 'VDS.mat'])

participants = fieldnames(headache_diary);

actlumus = struct2cell(actlumus);
headache_diary = struct2cell(headache_diary);

bad_trials = [zeros(1,7);zeros(1,7);zeros(1,7);zeros(1,7);[0 0 0 0 0 0 1]];

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
    
    % Convert light and mEDI data to log scale
%     vd_cleaned.LIGHT(vd_cleaned.LIGHT==0) = 0.009;
%     vd_cleaned.LIGHT = log(vd_cleaned.LIGHT);
%     vd_cleaned.MELANOPICEDI(vd_cleaned.MELANOPICEDI==0) = 0.009;
%     vd_cleaned.MELANOPICEDI = log(vd_cleaned.MELANOPICEDI);

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
    mEDI = NaN*ones(length(Day),1);
    Light = NaN*ones(length(Day),1);
    Min250_B10 = NaN*ones(length(Day),1);
    Min1000_B10 = NaN*ones(length(Day),1);
    Max10_E3 = NaN*ones(length(Day),1);
    Max1_D6 = NaN*ones(length(Day),1);
    D6 = NaN*ones(length(Day),1);
    B10 = NaN*ones(length(Day),1);
    B10l = NaN*ones(length(Day),1);
    E3 = NaN*ones(length(Day),1);

    for d = 1:length(Day)
        % remove data from days where the device was removed, or there
        % is incomplete data for the day
        if bad_trials(i,d)==0
            for h = 1:24
                Light_hr(d,h) = nanmedian(vd_cleaned.LIGHT(vd_cleaned.day==Day(d) & vd_cleaned.hour==Hours(h)));
                mEDI_hr(d,h) = nanmedian(vd_cleaned.MELANOPICEDI(vd_cleaned.day==Day(d) & vd_cleaned.hour==Hours(h)));
            end
            mEDI(d,1) = nanmedian(mEDI_hr(d,:));
            Light(d,1) = nanmedian(Light_hr(d,:));
            D6(d,1) = nanmedian(vd_cleaned.MELANOPICEDI(vd_cleaned.day==Day(d) & vd_cleaned.hour<6));
            B10(d,1) = nanmedian(vd_cleaned.MELANOPICEDI(vd_cleaned.day==Day(d) & vd_cleaned.hour>7 & vd_cleaned.hour<17));
            E3(d,1) = nanmedian(vd_cleaned.MELANOPICEDI(vd_cleaned.day==Day(d) & vd_cleaned.hour>=20 & vd_cleaned.hour<23));
            B10l(d,1) = nanmedian(vd_cleaned.LIGHT(vd_cleaned.day==Day(d) & vd_cleaned.hour>=7 & vd_cleaned.hour<17 & ~isnan(vd_cleaned.LIGHT)));
            
            % percentage over a time period of certain light exposures
            Min250_B10(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.MELANOPICEDI>250 & vd_cleaned.day==Day(d) & vd_cleaned.hour>=7 & vd_cleaned.hour<17))./600;
            Min1000_B10(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.MELANOPICEDI>1000 & vd_cleaned.day==Day(d) & vd_cleaned.hour>=7 & vd_cleaned.hour<17))./600;
            Max10_E3(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.MELANOPICEDI<10 & vd_cleaned.day==Day(d) & vd_cleaned.hour>=20 & vd_cleaned.hour<23))./180;
            Max1_D6(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.MELANOPICEDI<1 & vd_cleaned.day==Day(d) & vd_cleaned.hour<6))./360;
           
            clear temp*
        end
    end
    % restructure actlumus data by day
    light_by_day = reshape(vd_cleaned.LIGHT,[1440,7]);
    mEDI_by_day = reshape(vd_cleaned.MELANOPICEDI,[1440,7]);
    
    t.Light = Light;
    t.Light_B10 = B10l;
    t.mEDI = mEDI;
    t.mEDI_D6 = D6;
    t.mEDI_B10 = B10;
    t.mEDI_E3 = E3;
    t.mEDI_min250 = Min250_B10;
    t.mEDI_min1000 = Min1000_B10;
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
        if bad_trials(i,X)==0
            c1 = [0 0 0];
        else
            c1 = [0.5 0.5 0.5];
        end
        fill([7+(24*(X-1)) 7+(24*(X-1)) 17+(24*(X-1)) 17+(24*(X-1))],log([0.001 100000 100000 0.001]),[1 1 0.8])
        hold on
        fill([20+(24*(X-1)) 20+(24*(X-1)) 23+(24*(X-1)) 23+(24*(X-1))],log([0.001 100000 100000 0.001]),[0.8 0.8 1])
        fill([0+(24*(X-1)) 0+(24*(X-1)) 6+(24*(X-1)) 6+(24*(X-1))],log([0.001 100000 100000 0.001]),[0.8 0.8 0.8])
        plot(x,y,'Color',c1)
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
    
    clear Light T250 Hr250 D5 B10 Min250* Min1000* Max10* Max1* 
    
    if i==1
        T = subject_data.summary{1,1};
    else
        T = [T;subject_data.summary{1,i}];
    end
end


participants = unique(T.record_id);

figure(100)
counter = 1;
for i = 1:length(participants)
    
    figure(100)
    subplot(length(participants),2,counter)
    plot(T.light_scale(T.record_id==participants(i)),T.Light(T.record_id==participants(i)),'.k','MarkerSize',12)
    hold on
    lsline
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [-0.1 5.1];
    [A,B] = corr(T.light_scale(T.record_id==participants(i) & ~isnan(T.Light)),T.Light(T.record_id==participants(i) & ~isnan(T.Light)),'Type','Spearman');
    title(['R = ' num2str(A) ', p = ' num2str(B)])
    xlabel('Light Sensitivity Scale (0 - 5)')
    ylabel('Luminance (lux)')
    counter = counter+1;
    
    figure(100)
    subplot(length(participants),2,counter)
    plot(T.pain_score(T.record_id==participants(i)),T.Light(T.record_id==participants(i)),'.k','MarkerSize',12)
    hold on
    lsline
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [-0.1 10.1];
    [A,B] = corr(T.pain_score(T.record_id==participants(i) & ~isnan(T.Light)),T.Light(T.record_id==participants(i) & ~isnan(T.Light)),'Type','Spearman');
    title(['R = ' num2str(A) ', p = ' num2str(B)])
    xlabel('HA Pain Scale (0 - 10)')
    ylabel('Luminance (lux)')
    counter = counter+1;
end
clear A B a b c

% pre-allocate
HaPrct = NaN*ones(length(participants),1); DisabilityPrct = NaN*ones(length(participants),1);
MigPrct = NaN*ones(length(participants),1); 
pain_scoreM = NaN*ones(length(participants),1); light_scaleM = NaN*ones(length(participants),1);
B10m = NaN*ones(length(participants),1); D6m = NaN*ones(length(participants),1);
E3m = NaN*ones(length(participants),1); B10ml = NaN*ones(length(participants),1);
B10_250m = NaN*ones(length(participants),1); B10_1000m = NaN*ones(length(participants),1);
E3_10m = NaN*ones(length(participants),1); D6_1m = NaN*ones(length(participants),1);
HAhrM = NaN*ones(length(participants),1); D6_1m = NaN*ones(length(participants),1);

for i = 1:length(participants)
    HaPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.ha==1))./length(T.record_id(T.record_id==participants(i)));
    MigPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.migraine==1))./length(T.record_id(T.record_id==participants(i)));
    DisabilityPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.disability==1))./length(T.record_id(T.record_id==participants(i)));
    boot2 = bootstrp(1000,@median,T.pain_score(T.record_id==participants(i)));
    pain_scoreM(i,:) = prctile(boot2,50);
    boot3 = bootstrp(1000,@median,T.light_scale(T.record_id==participants(i)));
    light_scaleM(i,:) = prctile(boot3,50);
    B10m(i,:) = nanmedian(T.mEDI_B10(T.record_id==participants(i)));
    E3m(i,:) = nanmedian(T.mEDI_E3(T.record_id==participants(i)));
    D6m(i,:) = nanmedian(T.mEDI_D6(T.record_id==participants(i)));
    B10_250m(i,:) = nanmedian(T.mEDI_min250(T.record_id==participants(i)));
    B10_1000m(i,:) = nanmedian(T.mEDI_min1000(T.record_id==participants(i)));
    E3_10m(i,:) = nanmedian(T.mEDI_max10(T.record_id==participants(i)));
    D6_1m(i,:) = nanmedian(T.mEDI_max1(T.record_id==participants(i)));
    E3m(i,:) = nanmedian(T.mEDI_E3(T.record_id==participants(i)));
    D6m(i,:) = nanmedian(T.mEDI_D6(T.record_id==participants(i)));
    B10ml(i,:) = nanmedian(T.Light_B10(T.record_id==participants(i)));
    HAhrM(i,:) = nanmedian(T.ha_hr(T.record_id==participants(i)));
    clear boot*
end

M = table(participants,'VariableNames',{'record_id'});
M.HaPrct = HaPrct; M.MigPrct = MigPrct; M.DisabilityPrct = DisabilityPrct;
M.pain_scoreM = pain_scoreM; M.light_scaleM = light_scaleM;
M.B10m = B10m; M.E3m = E3m; M.D6m = D6m; M.B10ml = B10ml;
M.B10_250m = B10_250m; M.B10_1000m = B10_1000m;
M.E3_10m = E3_10m; M.D6_1m = D6_1m; M.HAhrM = HAhrM;
clear lightM light_scaleM pain_scoreM *Lo *Hi *Prct boot* mEDImin* LightVar B10* D6* E3*



%% Daytime, evening, night

figure
subplot(1,2,1)
plot(ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.B10m,'ok','MarkerFaceColor','y')
hold on
plot(1,nanmean(M.B10m),'ys')

plot(2*ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.E3m,'ok','MarkerFaceColor','b')
plot(2,nanmean(M.E3m),'bs')

plot(3*ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.D6m,'ok','MarkerFaceColor','k')
plot(3,nanmean(M.D6m),'ks')

ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 4];
title('Melanopic EDI by time of day')
xlabel('Time of Day')
ylabel('Melanopic EDI (lux)')

subplot(1,2,2)
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

figure
plot(ones(length(participants),1)+0.1*(rand(length(participants),1)-0.5),M.B10ml,'ok','MarkerFaceColor','y')

ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 2];
title('Illuminance levels during B10')
xlabel('Time of Day')
ylabel('Illuminance (lux)')

% Relationship between light sensitivity, light, headache pain, migraine frequency, and
% disability
figure

subplot(1,5,1)
plot(M.light_scaleM,M.pain_scoreM,'.k','MarkerSize',20)
lsline
[A,B] = corr(M.light_scaleM,M.pain_scoreM,'Type','Spearman');
title(['R = ' num2str(A) ', p = ' num2str(B)])
xlabel('light scale (0-5)')
ylabel('Pain score (0-10)')
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 6]; ax.YLim = [0 10];

subplot(1,5,2)
plot(M.light_scaleM,M.B10ml,'.k','MarkerSize',20)
lsline
[A,B] = corr(M.light_scaleM,M.B10ml,'Type','Spearman');
title(['R = ' num2str(A) ', p = ' num2str(B)])
xlabel('light scale (0-5)')
ylabel('Median illuminance Bright 10 hr (lux)')
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 6]; ax.YLim = [0 200];

subplot(1,5,3)
plot(M.DisabilityPrct,M.B10ml,'.k','MarkerSize',20)
lsline
[A,B] = corr(M.DisabilityPrct,M.B10ml,'Type','Spearman');
title(['R = ' num2str(A) ', p = ' num2str(B)])
xlabel('% Days with disability')
ylabel('Median illuminance Bright 10 hr (lux)')
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 1]; ax.YLim = [0 200];

subplot(1,5,4)
plot(M.MigPrct,M.B10ml,'.k','MarkerSize',20)
lsline
[A,B] = corr(M.MigPrct,M.B10ml,'Type','Spearman');
xlabel('% Days with migraine')
ylabel('Median illuminance Bright 10 hr (lux)')
title(['R = ' num2str(A) ', p = ' num2str(B)])
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 1]; ax.YLim = [0 200];

subplot(1,5,5)
plot(M.HAhrM,M.B10ml,'.k','MarkerSize',20)
lsline
[A,B] = corr(M.HAhrM,M.B10ml,'Type','Spearman');
xlabel('average duration of headache')
ylabel('Median illuminance Bright 10 hr (lux)')
title(['R = ' num2str(A) ', p = ' num2str(B)])
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 24]; ax.YLim = [0 200];


figure

subplot(1,4,1)
plot(M.light_scaleM,M.B10_250m,'.k','MarkerSize',20)
lsline
[A,B] = corr(M.light_scaleM,M.B10_250m,'Type','Spearman');
title(['R = ' num2str(A) ', p = ' num2str(B)])
xlabel('light scale (0-5)')
ylabel('Median % time >250 melanopic EDI')
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 6]; ax.YLim = [0 1];

subplot(1,4,2)
plot(M.DisabilityPrct,M.B10_250m,'.k','MarkerSize',20)
lsline
[A,B] = corr(M.DisabilityPrct,M.B10_250m,'Type','Spearman');
title(['R = ' num2str(A) ', p = ' num2str(B)])
xlabel('% Days with disability')
ylabel('Median % time >250 melanopic EDI')
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 1]; ax.YLim = [0 1];

subplot(1,4,3)
plot(M.MigPrct,M.B10_250m,'.k','MarkerSize',20)
lsline
[A,B] = corr(M.MigPrct,M.B10_250m,'Type','Spearman');
xlabel('% Days with migraine')
ylabel('Median % time >250 melanopic EDI')
title(['R = ' num2str(A) ', p = ' num2str(B)])
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 1]; ax.YLim = [0 1];

subplot(1,4,4)
plot(M.HAhrM,M.B10_250m,'.k','MarkerSize',20)
lsline
[A,B] = corr(M.HAhrM,M.B10_250m,'Type','Spearman');
xlabel('average duration of headache')
ylabel('Median % time >250 melanopic EDI')
title(['R = ' num2str(A) ', p = ' num2str(B)])
ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 24]; ax.YLim = [0 1];

%% Mixed effects models

mdl_lightSens = fitlme(T,'Light~light_scale+(1|record_id)');
mdl_lightHa = fitlme(T,'Light~pain_score+(1|record_id)');
mdl_lightDisability = fitlme(T,'Light~disability+(1|record_id)');
mdl_lightMigraine = fitlme(T,'Light~migraine+(1|record_id)');