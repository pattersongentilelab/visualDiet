 % Actlumus data organization
% Some light metrics based on Guidolin et al. "Protocol for a prospective, multicentre, 
% cross-sectional cohort study to assess personal light exposure." medRxiv (2024): 2024-02.

data_path = getpref('visualDiet','visualDietDataPath');

load([data_path 'VDS.mat'])
load([data_path 'surveyDataFixed.mat'])
load([data_path '/sleepPA_M.mat'])
load([data_path '/sleepPA_T'],'paT','sleepT')
load([data_path '/weatherNov24toMarch25.mat'])
load([data_path '/haQuestionnaireVD'],'haQ')
load([data_path '/Actlumus/Actlumus validation/mdlRFupdated2.mat'],'Mdl')
load('/Users/pattersonc/Library/CloudStorage/OneDrive-Children''sHospitalofPhiladelphia/Research/Pfizer Registry/Analysis/assocSxHA/CAMS_ChopAll_Aug2024.mat','CAMS')

addpath '/Users/pattersonc/Documents/MATLAB/commonFx'

participants = fieldnames(headache_diary);

actlumus = struct2cell(actlumus);
headache_diary = struct2cell(headache_diary);
surveys = surveys(~isnan(surveys.record_id),:);


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
    
    % Apply wear/non-wear/night filter
    [vd_cleaned,prctDay,prctNight,prctAll] = wearMdl(vd_cleaned,hd,Mdl);

    % vd_cleaned.LIGHT(vd_cleaned.wear=='non-wear') = NaN;
    % vd_cleaned.MELANOPICEDI(vd_cleaned.wear=='non-wear') = NaN;

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
    GoodDay = zeros(length(Day),1);
    GoodNight = zeros(length(Day),1);
    GoodAll = zeros(length(Day),1);
   
    for d = 1:length(Day)

        for h = 1:24
            Light_hr(d,h) = mean(vd_cleaned.LIGHT(vd_cleaned.day==Day(d) & vd_cleaned.hour==Hours(h) & ~isnan(vd_cleaned.LIGHT))); % photopic light
            mEDI_hr(d,h) = mean(vd_cleaned.MELANOPICEDI(vd_cleaned.day==Day(d) & vd_cleaned.hour==Hours(h) & ~isnan(vd_cleaned.MELANOPICEDI)));
        end

        Light(d,1) = sum(vd_cleaned.LIGHT(vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.LIGHT)))./60; % calculate lux*hr
        mEDI(d,1) = sum(vd_cleaned.MELANOPICEDI(vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.MELANOPICEDI)))./60; % calculate lux*hr
        mEDI_M(d,1) = sum(vd_cleaned.MELANOPICEDI(vd_cleaned.hour>=7 & vd_cleaned.hour<9 & vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.MELANOPICEDI)))./60; 
        mEDI_A(d,1) = sum(vd_cleaned.MELANOPICEDI(vd_cleaned.hour>=15 & vd_cleaned.hour<18 & vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.MELANOPICEDI)))./60; 
        mEDI_B(d,1) = sum(vd_cleaned.MELANOPICEDI(vd_cleaned.hour>=21 & vd_cleaned.day==Day(d) & ~isnan(vd_cleaned.MELANOPICEDI)))./60;

        if prctDay(:,d)>=0.8
            GoodDay(d,1) = 1;
        end

        if prctNight(:,d)>=0.8
            GoodNight(d,1) = 1;
        end

        if prctAll(:,d)>=0.8
            GoodAll(d,1) = 1;
        end
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
    
    t.Light = Light;
    t.mEDI = mEDI;
    t.mEDI_M = mEDI_M;
    t.mEDI_A = mEDI_A;
    t.mEDI_B = mEDI_B;
    t.mEDI_min250 = Min250_B10;
    t.light_min1000 = Min1000_B10l;
    t.mEDI_max10 = Max10_E3;
    t.mEDI_max1 = Max1_D6;
    t.PrctDay = prctDay(1:7)';
    t.PrctNight = prctNight(1:7)';
    t.PrctAll = prctAll(1:7)';
    t.GoodDay = GoodDay;
    t.GoodNight = GoodNight;
    t.GoodAll = GoodAll;
    
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
    % pause
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

%% Remove non-adherent days, and participants with < 3 days of usuable data

% T = T(T.GoodAll==1,:);
participants = unique(T.record_id);
haQ = haQ(ismember(haQ.record_id,participants),:);
sleepM = sleepM(ismember(sleepM.ID,participants),:);
paM = paM(ismember(paM.ID,participants),:);

M = summaryLightData(T,surveys,haQ);

%% add factors to T
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

%% Calculate CAMS
haASx = [M.nausea M.vomiting M.assoc_light M.assoc_sound M.assoc_smell M.assoc_lighthead...
    M.assoc_spinning M.assoc_balance M.assoc_thinking M.vis_blurry M.vis_double M.assoc_ringing M.assoc_neckpain];

M.aSx_count = sum(haASx,2);

binary_hx = cell(size(haASx));
binary_struct = NaN*ones(size(haASx,2),1);
for x = 1:size(haASx,2)
    temp = haASx(:,x);
    outcome = unique(temp);
        for y = 1:size(haASx,1)
            binary_struct(x,:) = 2;
                switch temp(y)
                    case outcome(1)
                        binary_hx{y,x} = [1 0];
                    case outcome(2)
                        binary_hx{y,x} = [0 1];
                end
        end
end

% concatonate each subjects binary outcomes
binary_Hx = NaN*ones(size(binary_hx,1),size(CAMS.var_pres,1)*2);
temp = [];
for x = 1:size(binary_hx,1)
    for y = 1:size(binary_hx,2)
        temp = cat(2,temp,cell2mat(binary_hx(x,y)));
    end
    binary_Hx(x,:) = temp;
    temp = [];
end

% Calculate MCA scores from original dataset
MCA_no = 12;
MCA_score_HAaSx = NaN*ones(size(binary_Hx,1),MCA_no);
for x = 1:size(binary_Hx,1)
    for y = 1:MCA_no
        temp1 = binary_Hx(x,:);
        temp2 = CAMS.MCA_model(:,y);
        r = temp1*temp2;
        MCA_score_HAaSx(x,y) = r;
    end
end

M.MCA1_HAaSx = MCA_score_HAaSx(:,1);
M.MCA2_HAaSx = -1*MCA_score_HAaSx(:,2);

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
        T.MVPAdur5to10(i) = PA.dur_MVPA_5_10_min;
    end
end
T.MVPAdur5to10(isnan(T.SleepMidpoint)) = NaN;

% add variance
participants_spl = unique(SPL.record_id);
for i = 1:length(participants_spl)
    SleepMidpointVar(i,:) = nanstd(T.SleepMidpoint(T.record_id==participants_spl(i)));
    TSTvar(i,:) = nanstd(T.TST(T.record_id==participants_spl(i)));
    SlEffVar(i,:) = nanstd(T.SlEff(T.record_id==participants_spl(i)));
    WASOvar(i,:) = nanstd(T.WASO(T.record_id==participants_spl(i)));
end
SPL.SleepMidpointVar = SleepMidpointVar; SPL.TSTvar = TSTvar; SPL.SlEffVar = SlEffVar; SPL.WASOvar = WASOvar;

%% save

save([data_path '/pilotVDwearRemoveBadupdated'],'M','T','SPL','subject_data')
