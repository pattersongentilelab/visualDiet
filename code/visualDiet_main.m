% Actlumus data organization
% Some light metrics based on Guidolin et al. "Protocol for a prospective, multicentre, 
% cross-sectional cohort study to assess personal light exposure." medRxiv (2024): 2024-02.

data_path = getpref('visualDiet','visualDietDataPath');

load([data_path 'VDS.mat'])
load([data_path 'surveyDataFixed.mat'])
load([data_path '/sleepPA_M.mat'])
load([data_path '/sleepPA_T'],'paT','sleepT')
load([data_path '/weatherNov24toMarch25.mat'])

participants = fieldnames(headache_diary);

actlumus = struct2cell(actlumus);
headache_diary = struct2cell(headache_diary);
surveys = surveys(~isnan(surveys.record_id),:);

hdp04 = headache_diary{4};% Change p04 light device since they were at LAX practice and always had actlumus with them
hdp04.light_device(hdp04.light_device==1) = 0;
headache_diary{4} = hdp04;

hdp19 = headache_diary{19};% Change p19 light device since there is no signal from the device on day 4
hdp19.light_device(4) = 1;
headache_diary{19} = hdp19;

figure

for i = 1:length(participants)
    vd = actlumus{i};
    hd = headache_diary{i};

    % Select actlumus data only on days that had a corresponding headache
    % diary + the following day to calculate D6
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
    
    vd_cleaned = vd(ismember(vd.day,[hd.day;hd.day(end)+1]),:);

    vd_cleaned.LIGHTlog = vd_cleaned.LIGHT;
    vd_cleaned.LIGHTlog(vd_cleaned.LIGHTlog<0.01) = 0.01;
    vd_cleaned.LIGHTlog = log(vd_cleaned.LIGHTlog);
    vd_cleaned.MELANOPICEDIlog = vd_cleaned.MELANOPICEDI;
    vd_cleaned.MELANOPICEDIlog(vd_cleaned.MELANOPICEDIlog<0.01) = 0.01;
    vd_cleaned.MELANOPICEDIlog = log(vd_cleaned.MELANOPICEDIlog);

    % restructure actlumus data by day
    light_by_day = reshape(vd_cleaned.LIGHTlog(1:10080),[1440,7]);
    mEDI_by_day = reshape(vd_cleaned.MELANOPICEDIlog(1:10080),[1440,7]);


    % Combine headache diary with actlumus mean metrics, calculating mean luminance
    % data over each hour by day
    t = hd(:,1);
    t.repeat = hd.repeat;
    t.month = hd.month;
    t.day = hd.day;
    t.year = hd.year;
    [daynum,dayname] = weekday(datetime(t.year,t.month,t.day));
    t.daynum = daynum;
    t.dayname = dayname;
    t.weekend = zeros(height(t),1);
    t.weekend(t.daynum==1|t.daynum==7) = 1;
    t.ha = hd.headache_today;
    t.migraine = hd.migraine_today_self_report;
    t.pain_score = hd.pain_score_today_nrs;
    t.pain_score(isnan(t.pain_score)) = 0;
    t.ha_start = categorical(hd.ha_start);
    t.ha_hr = hd.ha_hr;
    t.light_scale = hd.light_scale;
    t.disability = hd.disability_today;
    t.ha_rescue = hd.rescue_meds_used_today;
    if iscell(hd.glasses_hr)
        hd.glasses_hr = NaN*ones(height(hd),1);
    end
    t.glasses_hr = hd.glasses_hr;
    t.light_device = hd.light_device;
    if i==11
        t.light_device = zeros(7,1); %participant marked >2 hrs for sport, but had device with them
    end
    t.actv_device = hd.actv_device;
    t.hd_comp = hd.headache_diary_complete;
    
    t.migraine(t.ha==0) = 0;
    t.disability(t.ha==0) = 0;
    t.ha_hr(t.ha==0) = 0;
    
    Hours = 0:1:23;
    Light_hr = NaN*ones(length(Day),length(Hours)+12);
    mEDI_hr = NaN*ones(length(Day),length(Hours)+12);
    mEDI_M = NaN*ones(length(Day),1);
    mEDI_A = NaN*ones(length(Day),1);
    mEDI_B = NaN*ones(length(Day),1);
    Min250_B10 = NaN*ones(length(Day),1);
    Min1000_B10l = NaN*ones(length(Day),1);
    Max10_E3 = NaN*ones(length(Day),1);
    Max1_D6 = NaN*ones(length(Day),1);
    Light = NaN*ones(length(Day),1);
    mEDI = NaN*ones(length(Day),1);
    cont_mEDI = NaN*ones(7,2040);
    cont_mEDItime = NaT([7 2040],"Format","hh:mm:ss");
   
    for d = 1:length(Day)
        % remove data from days where the device was removed, or there
        % is incomplete data for the day
        if t.light_device(d)==0

            for h = 1:24
                Light_hr(d,h) = mean(vd_cleaned.LIGHT(vd_cleaned.day==Day(d) & vd_cleaned.hour==Hours(h) & ~isnan(vd_cleaned.LIGHT))); % photopic light
                mEDI_hr(d,h) = mean(vd_cleaned.MELANOPICEDI(vd_cleaned.day==Day(d) & vd_cleaned.hour==Hours(h) & ~isnan(vd_cleaned.MELANOPICEDI)));
            end

            Light(d,1) = sum(vd_cleaned.LIGHT(vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.LIGHT)))./60; % calculate lux*hr
            mEDI(d,1) = sum(vd_cleaned.MELANOPICEDI(vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.MELANOPICEDI)))./60; % calculate lux*hr
            mEDI_M(d,1) = mean(vd_cleaned.MELANOPICEDIlog(vd_cleaned.hour>=6 & vd_cleaned.hour<8 & vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.MELANOPICEDIlog))); 
            mEDI_A(d,1) = mean(vd_cleaned.MELANOPICEDIlog(vd_cleaned.hour>=15 & vd_cleaned.hour<18 & vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.MELANOPICEDIlog))); 
            mEDI_B(d,1) = mean(vd_cleaned.MELANOPICEDIlog(vd_cleaned.hour>=21 & vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.MELANOPICEDIlog)));
            % time period of certain light exposures
            Min250_B10(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.MELANOPICEDI>250 & vd_cleaned.day==Day(d) & vd_cleaned.hour>=7 & vd_cleaned.hour<17))./(10*60);
            Min1000_B10l(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.LIGHT>1000 & vd_cleaned.day==Day(d)));
            Max10_E3(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.MELANOPICEDI<10 & vd_cleaned.day==Day(d) & vd_cleaned.hour>=20 & vd_cleaned.hour<23))./(3*60);
            Max1_D6(d,1) = length(vd_cleaned.MELANOPICEDI(vd_cleaned.MELANOPICEDI<1 & vd_cleaned.day==Day(d) & vd_cleaned.hour<6))./(6*60);
          % continuous mEDI for B10 and D6 midpoint
          if d<7
            cont_mEDI(d,:) = vd_cleaned.MELANOPICEDIlog(vd_cleaned.day==Day(d) | (vd_cleaned.day==Day(d+1) & vd_cleaned.hour<10));
            cont_mEDItime(d,:) = vd_cleaned.TIME(vd_cleaned.day==Day(d) | (vd_cleaned.day==Day(d+1) & vd_cleaned.hour<10));
          else
              LL = vd_cleaned.MELANOPICEDIlog(vd_cleaned.day==Day(d) | (vd_cleaned.day==Day(end)+1 & vd_cleaned.hour<10))';
              TT = vd_cleaned.TIME(vd_cleaned.day==Day(d) | (vd_cleaned.day==Day(end)+1 & vd_cleaned.hour<10))';
              if length(LL)<2040
                  sss = 2040 - length(LL);
                  LL = [LL NaN*ones(1,sss)];
                  TT = [TT NaT([1 sss])];
              end
              cont_mEDI(d,:) = LL;
              cont_mEDItime(d,:) = TT;
          end
            clear temp*
        end
    end
    
    t.Light = Light;
    t.mEDI = mEDI;
    t.mEDI_M = mEDI_M;
    t.mEDI_A = mEDI_A;
    t.mEDI_B = mEDI_B;
    t.mEDI_min250 = Min250_B10;
    t.light_min1000 = Min1000_B10l;
    t.mEDI_max10 = Max10_E3;
    t.mEDI_max1 = Max1_D6;
    
    subject_data.summary{:,i} = t;
    subject_data.light_hr{:,i} = Light_hr;
    subject_data.light_by_day{:,i} = light_by_day;
    subject_data.mEDI_hr{:,i} = mEDI_hr;
    subject_data.mEDI_by_day{:,i} = mEDI_by_day;
    subject_data.cont_mEDI{:,i} = cont_mEDI;
    subject_data.cont_mEDItime{:,i} = cont_mEDItime;
    
    hold on
    x = 0:0.01667:24;
    

    for X = 1:length(Day)
        y = light_by_day(:,X);
        y2 = mEDI_by_day(:,X);
        c1 = [0.5 0.5 0.5];
        c2 = [0.2 0.2 0.2];
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
    pause
    clf
end

%% determine light timing

B10midpoint = NaT([length(participants) 7],"Format","hh:mm:ss");
D6midpoint = NaT([length(participants) 7],"Format","hh:mm:ss");

for i = 1:length(participants)
    temp = squeeze(subject_data.cont_mEDI{i});
    temp2 = squeeze(subject_data.cont_mEDItime{i});
    for d = 1:size(cont_mEDI,1)

        Lt = temp(d,:);
        Tm = temp2(d,:);       
        for sl = 1:length(Lt)-601
            B10(sl,1) = nansum(Lt(:,sl:sl+600));
        end

        Dk = temp(d,1021:end);
        TmDk = temp2(d,1021:end);
        for sl2 = 1:length(Dk)-361
            D6(sl2,1) = nansum(Dk(:,sl2:sl2+360));
        end

        stB10 = Tm(B10==max(B10));
        if width(stB10)>1
           spt = floor(width(stB10)./2);
           stB10 = stB10(:,spt);
        end
        B10midpoint(i,d) = stB10+hours(5);

        stD6 = TmDk(D6==min(D6));
        if width(stD6)>1
           spt = floor(width(stD6)./2);
           stD6 = stD6(:,spt);
        end
        D6midpoint(i,d) = stD6+hours(3);
    end
end

T.B10midpoint = timeofday(reshape(B10midpoint,[140 1]));
T.D6midpoint = timeofday(reshape(D6midpoint,[140 1]));
T.B10midpointNum = hours(T.B10midpoint);
T.D6midpointNum = hours(T.D6midpoint);
T.D6midpointNum(T.D6midpointNum>=12) = T.D6midpointNum(T.D6midpointNum>=12)-24;

T.glasses_hr(ismissing(T.glasses_hr)) = "0";
T.glasses_hr(T.glasses_hr=="") = "0";
T.glasses_hr = str2double(T.glasses_hr);

participants = unique(T.record_id);


% pre-allocate
HaPrct = NaN*ones(length(participants),1); DisabilityPrct = NaN*ones(length(participants),1);
MigPrct = NaN*ones(length(participants),1); 
pain_scoreM = NaN*ones(length(participants),1); light_scaleM = NaN*ones(length(participants),1); glasses_hrM = NaN*ones(length(participants),1);
Light = NaN*ones(length(participants),1);
mEDI = NaN*ones(length(participants),1);
mEDI_M = NaN*ones(length(participants),1);
mEDI_A = NaN*ones(length(participants),1);
mEDI_B = NaN*ones(length(participants),1);
B10_250m = NaN*ones(length(participants),1); B10_1000m = NaN*ones(length(participants),1);
E3_10m = NaN*ones(length(participants),1); D6_1m = NaN*ones(length(participants),1);
HAhrM = NaN*ones(length(participants),1);
Month = NaN*ones(length(participants),1);


for i = 1:length(participants)
    HaPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.ha==1))./length(T.record_id(T.record_id==participants(i)));
    MigPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.migraine==1))./length(T.record_id(T.record_id==participants(i)));
    DisabilityPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.disability==1))./length(T.record_id(T.record_id==participants(i)));
    boot2 = bootstrp(1000,@median,T.pain_score(T.record_id==participants(i)));
    pain_scoreM(i,:) = prctile(boot2,50);
    boot3 = bootstrp(1000,@median,T.light_scale(T.record_id==participants(i)));
    light_scaleM(i,:) = prctile(boot3,50);
    boot4 = bootstrp(1000,@median,T.glasses_hr(T.record_id==participants(i)));
    glasses_hrM(i,:) = prctile(boot4,50);
    Light(i,:) = nanmedian(T.Light(T.record_id==participants(i)));
    mEDI(i,:) = nanmedian(T.mEDI(T.record_id==participants(i)));
    mEDI_M(i,:) = nanmedian(T.mEDI_M(T.record_id==participants(i)));
    mEDI_A(i,:) = nanmedian(T.mEDI_A(T.record_id==participants(i)));
    mEDI_B(i,:) = nanmedian(T.mEDI_B(T.record_id==participants(i)));
    B10_250m(i,:) = nanmedian(T.mEDI_min250(T.record_id==participants(i)));
    B10_1000m(i,:) = nanmedian(T.light_min1000(T.record_id==participants(i)));
    E3_10m(i,:) = nanmedian(T.mEDI_max10(T.record_id==participants(i)));
    D6_1m(i,:) = nanmedian(T.mEDI_max1(T.record_id==participants(i)));
    HAhrM(i,:) = nanmedian(T.ha_hr(T.record_id==participants(i)));
    Month(i,:) = mode(T.month(T.record_id==participants(i)));
    B10mid(i,:) = nanmean(T.B10midpoint(T.record_id==participants(i)));
    D6mid(i,:) = nanmean(T.D6midpoint(T.record_id==participants(i)));
    B10midN(i,:) = nanmean(T.B10midpointNum(T.record_id==participants(i)));
    D6midN(i,:) = nanmean(T.D6midpointNum(T.record_id==participants(i)));
    WD_B10(i,:) = nanmean(T.B10midpointNum(T.record_id==participants(i) & T.weekend==0));
    WD_D6(i,:) = nanmean(T.D6midpointNum(T.record_id==participants(i) & T.weekend==0));
    WE_B10(i,:) = nanmean(T.B10midpointNum(T.record_id==participants(i) & T.weekend==1));
    WE_D6(i,:) = nanmean(T.D6midpointNum(T.record_id==participants(i) & T.weekend==1));
    clear boot*
end

M = table(participants,'VariableNames',{'record_id'});

% Add additional info from survey data
surveys = surveys(ismember(surveys.record_id,M.record_id),:);
M.sex = surveys.patient_sex(surveys.redcap_event_name=='visit_1_arm_1');
M.age = surveys.patient_age_today(surveys.redcap_event_name=='visit_1_arm_1');
M.Month = categorical(Month);
M.Ha = surveys.days_any_ha(surveys.redcap_event_name=='visit_2_arm_1');
M.BadHa = surveys.days_bad_ha(surveys.redcap_event_name=='visit_2_arm_1');
M.pedmidas_score = surveys.pedmidas_score(surveys.redcap_event_name=='visit_3_arm_1');
vlsq8 = [surveys.lsa_4(surveys.redcap_event_name=='visit_2_arm_1') surveys.lsa_7(surveys.redcap_event_name=='visit_2_arm_1')...
    surveys.sensitivity_score(surveys.redcap_event_name=='visit_2_arm_1') surveys.lsa_1(surveys.redcap_event_name=='visit_2_arm_1')...
    surveys.lsa_9(surveys.redcap_event_name=='visit_2_arm_1') surveys.lsa_11(surveys.redcap_event_name=='visit_2_arm_1')...
    surveys.lsa_14(surveys.redcap_event_name=='visit_2_arm_1') surveys.lsa_16(surveys.redcap_event_name=='visit_2_arm_1')];
M.vlsq8 = sum(vlsq8,2);
M.pain_fear = surveys.fear_score(surveys.redcap_event_name=='visit_2_arm_1');
M.pain_avoid = surveys.avoid_score(surveys.redcap_event_name=='visit_2_arm_1');
M.fopqc = surveys.fopqc_score(surveys.redcap_event_name=='visit_2_arm_1');
M.CM = zeros(height(M),1);
M.CM(M.Ha>=15 & M.BadHa>=8) = 1;
M.pedmidas_grade = zeros(height(M),1);
M.pedmidas_grade(M.pedmidas_score>=4 & M.pedmidas_score<10) = 1;
M.pedmidas_grade(M.pedmidas_score>=10 & M.pedmidas_score<17) = 2;
M.pedmidas_grade(M.pedmidas_score>=17) = 3;
M.pedmidas_grade = categorical(M.pedmidas_grade,0:3,{'none','mild','moderate','severe'});
M.sleepDis = surveys.sleep_dis_level(surveys.redcap_event_name=='visit_3_arm_1');
M.sleepImp = surveys.sleep_imp_level(surveys.redcap_event_name=='visit_3_arm_1');
M.DisBi = zeros(height(M),1);
M.DisBi(M.pedmidas_grade=='moderate' | M.pedmidas_grade=='severe') = 1;
M.FopBi = zeros(height(M),1);
M.FopBi(M.fopqc>=30) = 1;
M.SlIbi = zeros(height(M),1);
M.SlIbi(M.sleepImp>=2) = 1;
M.SlDbi = zeros(height(M),1);
M.SlDbi(M.sleepDis>=2) = 1;
M.VsBi = zeros(height(M),1);
M.VsBi(M.vlsq8>24) = 1;
M.AgeBi = zeros(height(M),1);
M.AgeBi(M.age>=18) = 1;


% add headache features
M.HaPrct = HaPrct; M.MigPrct = MigPrct; M.DisabilityPrct = DisabilityPrct;
M.pain_scoreM = pain_scoreM; M.light_scaleM = light_scaleM; M.glasses_hrM = glasses_hrM; 
M.HAhrM = HAhrM;

% add light measurements
M.Light = Light; M.mEDI = mEDI; M.mEDI_M = mEDI_M; M.mEDI_A = mEDI_A; M.mEDI_B = mEDI_B; M.B10_1000m = B10_1000m; M.B10_250m = B10_250m;
M.E3_10m = E3_10m; M.D6_1m = D6_1m; M.B10mid = B10mid; M.D6mid = D6mid; M.B10midN = B10midN; M.D6midN = D6midN; M.WD_B10 = WD_B10; M.WE_B10 = WE_B10; M.WD_D6 = WD_D6; M.WE_D6 = WE_D6; 
clear lightM light_scaleM pain_scoreM *Lo *Hi *Prct boot* mEDImin* LightVar B10* D6* E3*

% add factors to T
T.fopqc = NaN*ones(height(T),1);
T.pedmidas = NaN*ones(height(T),1);
T.age = NaN*ones(height(T),1);
T.Ha = NaN*ones(height(T),1);
T.BadHa = NaN*ones(height(T),1);
T.VS = NaN*ones(height(T),1);
T.CM = NaN*ones(height(T),1);
T.pedmidas_grade = NaN*ones(height(T),1);
T.sleep_imp = NaN*ones(height(T),1);
T.sleep_dis = NaN*ones(height(T),1);
T.vsHigh = zeros(height(T),1);
T.vsHigh(T.light_scale>=3) = 1;

for i = 1:length(participants)
    T.fopqc(T.record_id==participants(i)) = M.fopqc(i);
    T.pedmidas(T.record_id==participants(i)) = M.pedmidas_score(i);
    T.age(T.record_id==participants(i)) = M.age(i);
    T.sex(T.record_id==participants(i)) = M.sex(i);
    T.Ha(T.record_id==participants(i)) = M.Ha(i);
    T.BadHa(T.record_id==participants(i)) = M.BadHa(i);
    T.VS(T.record_id==participants(i)) = M.vlsq8(i);
    T.CM(T.record_id==participants(i)) = M.CM(i);
    T.pedmidas_grade(T.record_id==participants(i)) = M.pedmidas_grade(i);
    T.sleep_imp(T.record_id==participants(i)) = M.sleepImp(i);
    T.sleep_dis(T.record_id==participants(i)) = M.sleepDis(i);
end


%% add weather and daylight data

% NWS philadelphia area weather data from https://www.weather.gov/wrh/Climate?wfo=phi
% daylight hrs from https://aa.usno.navy.mil/calculated/durdaydark?year=2025&task=0&lat=39.9526&lon=-75.1652&label=Philadelphia%2C+PA&tz=0.00&tz_sign=-1&submit=Get+Data
% Trace amount of precipitation was counted as 0

T.Daylight = NaN*ones(height(T),1);
T.Temp = NaN*ones(height(T),1);
T.Precip = NaN*ones(height(T),1);

for i = 1:length(participants)
    tempP = T(T.record_id==participants(i),:);
    for j = 1:height(tempP)
        tempW = weather_data(weather_data.Day==tempP.day(j) & weather_data.Month==tempP.month(j) & weather_data.Year==tempP.year(j),:);
        T.Daylight(T.record_id==participants(i) & T.day==tempP.day(j) & T.month==tempP.month(j) & T.year==tempP.year(j)) = tempW.DaylightHr;
        T.Temp(T.record_id==participants(i) & T.day==tempP.day(j) & T.month==tempP.month(j) & T.year==tempP.year(j)) = tempW.AvgTemp;
        T.Precip(T.record_id==participants(i) & T.day==tempP.day(j) & T.month==tempP.month(j) & T.year==tempP.year(j)) = tempW.Precip;
    end
end

T.Cold = zeros(height(T),1);
T.Cold(T.Temp<42) = 1;
T.Rainy = zeros(height(T),1);
T.Rainy(T.Precip>0) = 1;
T.Dark = zeros(height(T),1);
T.Dark(T.Daylight<10.1) = 1;

%% add sleep and physical activity data
SPL = M(ismember(M.record_id,sleepM.ID),:);
SPL.TST = sleepM.avg_TST;
SPL.SlEff = sleepM.avg_Sleep_efficiency;
SPL.WASO = sleepM.avg_WASO;
SPL.sleepOnset = sleepM.avg_sleeponset;
SPL.wakeOnset = sleepM.avg_wakeonset;
SPL.sleepMidpoint = sleepM.avg_sleeponset + ((sleepM.avg_wakeonset - sleepM.avg_sleeponset)./2);
SPL.MVPAdur5to10 = paM.avg_dur_MVPA_5_10_min;
SPL.MVPAdur10plus = paM.avg_dur_MVPA_more_than_10_min;

% add sleep and physical activity data by day

calendar_day = datetime(T.year,T.month,T.day);
sleepT.calendar_date = datetime(sleepT.calendar_date);
paT.calendar_date = datetime(paT.calendar_date);
T.TST = NaN*ones(height(T),1);
T.SlEff = NaN*ones(height(T),1);
T.WASO = NaN*ones(height(T),1);
T.SleepMidpoint = NaN*ones(height(T),1);
for i = 1:height(T)
    SL = sleepT(sleepT.ID==T.record_id(i) & sleepT.calendar_date==calendar_day(i),:);
    PA = paT(paT.ID==T.record_id(i) & paT.calendar_date==calendar_day(i),:);
    if ~isempty(SL)
        T.TST(i) = SL.TST;
        T.SlEff(i) = SL.Sleep_efficiency;
        T.WASO(i) = SL.WASO;
        T.SleepMidpoint(i) = SL.sleeponset + ((SL.wakeonset - SL.sleeponset)./2);
    end
end

%% save

save([data_path '/pilotVD'],'M','T','SPL','subject_data')