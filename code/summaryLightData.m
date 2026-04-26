function [M] = summaryLightData(T,surveys,haQ)

%% calculate summary data

participants = unique(T.record_id);

M = table(participants,'VariableNames',{'record_id'});

% pre-allocate
M.HaPrct = NaN*ones(length(participants),1); M.DisabilityPrct = NaN*ones(length(participants),1);
M.MigPrct = NaN*ones(length(participants),1); 
M.pain_scoreM = NaN*ones(length(participants),1); M.light_scaleM = NaN*ones(length(participants),1); M.glasses_hrM = NaN*ones(length(participants),1);
M.Light = NaN*ones(length(participants),1);
M.mEDI = NaN*ones(length(participants),1); M.mEDI_M = NaN*ones(length(participants),1);
M.mEDI_A = NaN*ones(length(participants),1); M.mEDI_B = NaN*ones(length(participants),1);
M.B10_250m = NaN*ones(length(participants),1); M.B10_1000m = NaN*ones(length(participants),1);
M.E3_10m = NaN*ones(length(participants),1); M.D6_1m = NaN*ones(length(participants),1);
M.HAhrM = NaN*ones(length(participants),1); M.Month = NaN*ones(length(participants),1);

M.B10mid = duration(zeros(height(M),1),0,0);
M.D6mid = duration(zeros(height(M),1),0,0);
M.B10midN = NaN*ones(length(participants),1);
M.D6midN = NaN*ones(length(participants),1);
M.WD_D6 = NaN*ones(length(participants),1);
M.WE_B10 = NaN*ones(length(participants),1);
M.WE_D6 = NaN*ones(length(participants),1);

for i = 1:length(participants)
    M.HaPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.ha==1))./length(T.record_id(T.record_id==participants(i)));
    M.MigPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.migraine==1))./length(T.record_id(T.record_id==participants(i)));
    M.DisabilityPrct(i,1) = length(T.record_id(T.record_id==participants(i) & T.disability==1))./length(T.record_id(T.record_id==participants(i)));
    boot2 = bootstrp(1000,@median,T.pain_score(T.record_id==participants(i)));
    M.pain_scoreM(i,:) = prctile(boot2,50);
    boot3 = bootstrp(1000,@median,T.light_scale(T.record_id==participants(i)));
    M.light_scaleM(i,:) = prctile(boot3,50);
    boot4 = bootstrp(1000,@median,T.glasses_hr(T.record_id==participants(i)));
    M.glasses_hrM(i,:) = prctile(boot4,50);
    M.Light(i) = median(T.Light(T.record_id==participants(i) & T.GoodDay==1 & ~isnan(T.Light)));
    M.mEDI(i) = median(T.mEDI(T.record_id==participants(i) & T.GoodDay==1 & ~isnan(T.Light)));
    M.mEDI_M(i) = median(T.mEDI_M(T.record_id==participants(i) & T.GoodDay==1 & ~isnan(T.Light)));
    M.mEDI_A(i) = median(T.mEDI_A(T.record_id==participants(i) & T.GoodDay==1 & ~isnan(T.Light)));
    M.mEDI_B(i) = median(T.mEDI_B(T.record_id==participants(i) & T.GoodNight==1 & ~isnan(T.Light)));
    M.B10_250m(i) = median(T.mEDI_min250(T.record_id==participants(i) & T.GoodDay==1 & ~isnan(T.Light)));
    M.B10_1000m(i) = median(T.light_min1000(T.record_id==participants(i) & T.GoodDay==1 & ~isnan(T.Light)));
    M.E3_10m(i) = median(T.mEDI_max10(T.record_id==participants(i) & T.GoodDay==1 & T.GoodNight==1 & ~isnan(T.Light)));
    M.D6_1m(i) = median(T.mEDI_max1(T.record_id==participants(i) & T.GoodNight==1 & ~isnan(T.Light)));
    M.HAhrM(i) = median(T.ha_hr(T.record_id==participants(i) & ~isnan(T.Light)));
    M.Month(i) = mode(T.month(T.record_id==participants(i) & ~isnan(T.Light)));
    M.B10mid(i) = mean(T.B10midpoint(T.record_id==participants(i) & ~isnan(T.Light)));
    M.D6mid(i) = mean(T.D6midpoint(T.record_id==participants(i)));
    M.B10midN(i) = mean(T.B10midpointNum(T.record_id==participants(i) & ~isnan(T.Light)));
    M.D6midN(i) = mean(T.D6midpointNum(T.record_id==participants(i) & ~isnan(T.Light)));
    M.WD_B10(i) = mean(T.B10midpointNum(T.record_id==participants(i) & T.weekend==0 & T.GoodDay==1 & ~isnan(T.Light)));
    M.WD_D6(i) = mean(T.D6midpointNum(T.record_id==participants(i) & T.weekend==0 & T.GoodNight==1 & ~isnan(T.Light)));
    M.WE_B10(i) = mean(T.B10midpointNum(T.record_id==participants(i) & T.weekend==1 & T.GoodDay==1 & ~isnan(T.Light)));
    M.WE_D6(i) = mean(T.D6midpointNum(T.record_id==participants(i) & T.weekend==1 & T.GoodNight==1 & ~isnan(T.Light)));
    clear boot*
end

% Add additional info from survey data
surveys = surveys(ismember(surveys.record_id,M.record_id),:);
M.sex = surveys.patient_sex(surveys.redcap_event_name=='visit_1_arm_1');
M.age = surveys.patient_age_today(surveys.redcap_event_name=='visit_1_arm_1');
M.Month = categorical(M.Month);
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
M.ha_sleep = haQ.ha_sleep;
M.cont = haQ.p_current_ha_pattern;
M.vis_spots = haQ.vision_aura_sx_baseline___spot;
M.vis_stars = haQ.vision_aura_sx_baseline___star;
M.vis_spots = haQ.vision_aura_sx_baseline___spot;
M.vis_flash = haQ.vision_aura_sx_baseline___light;
M.vis_zigzag = haQ.vision_aura_sx_baseline___zigzag;
M.vis_blurry = haQ.vision_aura_sx_baseline___blur;
M.vis_double = haQ.vision_aura_sx_baseline___double_vis;
M.vis_heat = haQ.vision_aura_sx_baseline___heat;
M.weak = haQ.assoc_sx_neuro_bil___weak;
M.nausea = haQ.assoc_sx_gi___naus;
M.vomiting = haQ.assoc_sx_gi___vomiting;
M.assoc_light = haQ.associated_sx___light;
M.assoc_sound = haQ.associated_sx___sound;
M.assoc_smell = haQ.associated_sx___smell;
M.assoc_lighthead = haQ.associated_sx___lighthead;
M.assoc_spinning = haQ.associated_sx___spinning;
M.assoc_balance = haQ.associated_sx___balance;
M.assoc_hear = haQ.associated_sx___hear;
M.assoc_ringing = haQ.associated_sx___ringing;
M.assoc_neckpain = haQ.associated_sx___neck_pain;
M.assoc_thinking = haQ.associated_sx___think;
M.assoc_talking = haQ.associated_sx___talk;

% % add headache features
% M.HaPrct = HaPrct; M.MigPrct = MigPrct; M.DisabilityPrct = DisabilityPrct;
% M.pain_scoreM = pain_scoreM; M.light_scaleM = light_scaleM; M.glasses_hrM = glasses_hrM; 
% M.HAhrM = HAhrM;
% 
% % add light measurements
% M.Light = Light; M.mEDI = mEDI; M.mEDI_M = mEDI_M; M.mEDI_A = mEDI_A; M.mEDI_B = mEDI_B; M.B10_1000m = B10_1000m; M.B10_250m = B10_250m;
% M.E3_10m = E3_10m; M.D6_1m = D6_1m; M.B10mid = B10mid; M.D6mid = D6mid; M.B10midN = B10midN; M.D6midN = D6midN; M.WD_B10 = WD_B10; M.WE_B10 = WE_B10; M.WD_D6 = WD_D6; M.WE_D6 = WE_D6; 

end