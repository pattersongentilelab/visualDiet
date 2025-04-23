% Actlumus data analysis
% Some light metrics based on Guidolin et al. "Protocol for a prospective, multicentre, 
% cross-sectional cohort study to assess personal light exposure." medRxiv (2024): 2024-02.

data_path = getpref('visualDiet','visualDietDataPath');
load([data_path '/pilotVD'],'M','T','subject_data')

participants = unique(M.record_id);

%% Power Analysis

sample_size = 5:1:75;

% Fear of pain

for i = 1:length(sample_size)
    for j = 1:1000
        sim_dataA = datasample(M.Light(M.FopBi==0),sample_size(i),'Replace',true);
        sim_dataB = datasample(M.Light(M.FopBi==1),sample_size(i),'Replace',true);
        sim_dataA2 = datasample(M.B10_1000m(M.FopBi==0),sample_size(i),'Replace',true);
        sim_dataB2 = datasample(M.B10_1000m(M.FopBi==1),sample_size(i),'Replace',true);
        sim_dataA3 = datasample(M.B10_250m(M.FopBi==0),sample_size(i),'Replace',true);
        sim_dataB3 = datasample(M.B10_250m(M.FopBi==1),sample_size(i),'Replace',true);
        sim_dataA4 = datasample(M.E3_10m(M.FopBi==0),sample_size(i),'Replace',true);
        sim_dataB4 = datasample(M.E3_10m(M.FopBi==1),sample_size(i),'Replace',true);
        sim_dataA5 = datasample(M.D6_1m(M.FopBi==0),sample_size(i),'Replace',true);
        sim_dataB5 = datasample(M.D6_1m(M.FopBi==1),sample_size(i),'Replace',true);
        sim_dataA6 = datasample(M.mEDI_M(M.FopBi==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.mEDI_M(M.FopBi==1),sample_size(i),'Replace',true);
        sim_dataA7 = datasample(M.mEDI_A(M.FopBi==0),sample_size(i),'Replace',true);
        sim_dataB7 = datasample(M.mEDI_A(M.FopBi==1),sample_size(i),'Replace',true);
        sim_dataA8 = datasample(M.mEDI_B(M.FopBi==0),sample_size(i),'Replace',true);
        sim_dataB8 = datasample(M.mEDI_B(M.FopBi==1),sample_size(i),'Replace',true); 
        noFOP(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6);mean(sim_dataA7);mean(sim_dataA8)];
        FOP(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6);mean(sim_dataB7);mean(sim_dataB8)];
        [~,pLightFOP(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorFOP(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDayFOP(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningFOP(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightFOP(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pMorningFOP(i,j)] = ttest2(sim_dataA6,sim_dataB6);
        [~,pAfternoonFOP(i,j)] = ttest2(sim_dataA7,sim_dataB7);
        [~,pBedFOP(i,j)] = ttest2(sim_dataA8,sim_dataB8);
    end
end
clear sim_data*

Plight = prctile(pLightFOP,80,2);
Poutdoor = prctile(pOutdoorFOP,80,2);
Pday = prctile(pDayFOP,80,2);
Pevening = prctile(pEveningFOP,80,2);
Pnight = prctile(pNightFOP,80,2);
Pmorning = prctile(pMorningFOP,80,2);
Pafternoon = prctile(pAfternoonFOP,80,2);
pBed = prctile(pBedFOP,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pmorning)
plot(sample_size,Pafternoon)
plot(sample_size,pBed)
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
title('low vs. high FOP')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI morning','mEDI afternoon','mEDI evening','p = 0.05','p = 0.01'})

% Disability
for i = 1:length(sample_size)
    for j = 1:1000
        sim_dataA = datasample(M.Light(M.DisBi==0),sample_size(i),'Replace',true);
        sim_dataB = datasample(M.Light(M.DisBi==1),sample_size(i),'Replace',true);
        sim_dataA2 = datasample(M.B10_1000m(M.DisBi==0),sample_size(i),'Replace',true);
        sim_dataB2 = datasample(M.B10_1000m(M.DisBi==1),sample_size(i),'Replace',true);
        sim_dataA3 = datasample(M.B10_250m(M.DisBi==0),sample_size(i),'Replace',true);
        sim_dataB3 = datasample(M.B10_250m(M.DisBi==1),sample_size(i),'Replace',true);
        sim_dataA4 = datasample(M.E3_10m(M.DisBi==0),sample_size(i),'Replace',true);
        sim_dataB4 = datasample(M.E3_10m(M.DisBi==1),sample_size(i),'Replace',true);
        sim_dataA5 = datasample(M.D6_1m(M.DisBi==0),sample_size(i),'Replace',true);
        sim_dataB5 = datasample(M.D6_1m(M.DisBi==1),sample_size(i),'Replace',true);
        sim_dataA6 = datasample(M.mEDI_M(M.DisBi==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.mEDI_M(M.DisBi==1),sample_size(i),'Replace',true);
        sim_dataA7 = datasample(M.mEDI_A(M.DisBi==0),sample_size(i),'Replace',true);
        sim_dataB7 = datasample(M.mEDI_A(M.DisBi==1),sample_size(i),'Replace',true);
        sim_dataA8 = datasample(M.mEDI_B(M.DisBi==0),sample_size(i),'Replace',true);
        sim_dataB8 = datasample(M.mEDI_B(M.DisBi==1),sample_size(i),'Replace',true);
        noDis(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6);mean(sim_dataA7);mean(sim_dataA8)];
        Dis(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6);mean(sim_dataB7);mean(sim_dataB8)];
        [~,pLightDis(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorDis(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDayDis(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningDis(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightDis(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pMorningDis(i,j)] = ttest2(sim_dataA6,sim_dataB6);
        [~,pAfternoonDis(i,j)] = ttest2(sim_dataA7,sim_dataB7);
        [~,pBedDis(i,j)] = ttest2(sim_dataA8,sim_dataB8);
    end
end
clear sim_data*

Plight = prctile(pLightDis,80,2);
Poutdoor = prctile(pOutdoorDis,80,2);
Pday = prctile(pDayDis,80,2);
Pevening = prctile(pEveningDis,80,2);
Pnight = prctile(pNightDis,80,2);
Pmorning = prctile(pMorningDis,80,2);
Pafternoon = prctile(pAfternoonDis,80,2);
pBed = prctile(pBedDis,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pmorning)
plot(sample_size,Pafternoon)
plot(sample_size,pBed)
title('low Disability vs. High Disability')
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI morning','mEDI afternoon','mEDI evening','p = 0.05','p = 0.01'})

% VLSQ8

for i = 1:length(sample_size)
    for j = 1:1000
        sim_dataA = datasample(M.Light(M.VsBi==0),sample_size(i),'Replace',true);
        sim_dataB = datasample(M.Light(M.VsBi==1),sample_size(i),'Replace',true);
        sim_dataA2 = datasample(M.B10_1000m(M.VsBi==0),sample_size(i),'Replace',true);
        sim_dataB2 = datasample(M.B10_1000m(M.VsBi==1),sample_size(i),'Replace',true);
        sim_dataA3 = datasample(M.B10_250m(M.VsBi==0),sample_size(i),'Replace',true);
        sim_dataB3 = datasample(M.B10_250m(M.VsBi==1),sample_size(i),'Replace',true);
        sim_dataA4 = datasample(M.E3_10m(M.VsBi==0),sample_size(i),'Replace',true);
        sim_dataB4 = datasample(M.E3_10m(M.VsBi==1),sample_size(i),'Replace',true);
        sim_dataA5 = datasample(M.D6_1m(M.VsBi==0),sample_size(i),'Replace',true);
        sim_dataB5 = datasample(M.D6_1m(M.VsBi==1),sample_size(i),'Replace',true);
        sim_dataA6 = datasample(M.mEDI_M(M.VsBi==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.mEDI_M(M.VsBi==1),sample_size(i),'Replace',true);
        sim_dataA7 = datasample(M.mEDI_A(M.VsBi==0),sample_size(i),'Replace',true);
        sim_dataB7 = datasample(M.mEDI_A(M.VsBi==1),sample_size(i),'Replace',true);
        sim_dataA8 = datasample(M.mEDI_B(M.VsBi==0),sample_size(i),'Replace',true);
        sim_dataB8 = datasample(M.mEDI_B(M.VsBi==1),sample_size(i),'Replace',true); 
        noVs(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6);mean(sim_dataA7);mean(sim_dataA8)];
        Vs(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6);mean(sim_dataB7);mean(sim_dataB8)];
        [~,pLightVs(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorVs(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDayVs(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningVs(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightVs(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pMorningVs(i,j)] = ttest2(sim_dataA6,sim_dataB6);
        [~,pAfternoonVs(i,j)] = ttest2(sim_dataA7,sim_dataB7);
        [~,pBedVs(i,j)] = ttest2(sim_dataA8,sim_dataB8);
    end
end
clear sim_data*

Plight = prctile(pLightVs,80,2);
Poutdoor = prctile(pOutdoorVs,80,2);
Pday = prctile(pDayVs,80,2);
Pevening = prctile(pEveningVs,80,2);
Pnight = prctile(pNightVs,80,2);
Pmorning = prctile(pMorningVs,80,2);
Pafternoon = prctile(pAfternoonVs,80,2);
pBed = prctile(pBedVs,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pmorning)
plot(sample_size,Pafternoon)
plot(sample_size,pBed)
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
title('low vs. high Vs')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI morning','mEDI afternoon','mEDI evening','p = 0.05','p = 0.01'})



% Chronic migraine
for i = 1:length(sample_size)
    for j = 1:1000
        sim_dataA = datasample(M.Light(M.CM==0),sample_size(i),'Replace',true);
        sim_dataB = datasample(M.Light(M.CM==1),sample_size(i),'Replace',true);
        sim_dataA2 = datasample(M.B10_1000m(M.CM==0),sample_size(i),'Replace',true);
        sim_dataB2 = datasample(M.B10_1000m(M.CM==1),sample_size(i),'Replace',true);
        sim_dataA3 = datasample(M.B10_250m(M.CM==0),sample_size(i),'Replace',true);
        sim_dataB3 = datasample(M.B10_250m(M.CM==1),sample_size(i),'Replace',true);
        sim_dataA4 = datasample(M.E3_10m(M.CM==0),sample_size(i),'Replace',true);
        sim_dataB4 = datasample(M.E3_10m(M.CM==1),sample_size(i),'Replace',true);
        sim_dataA5 = datasample(M.D6_1m(M.CM==0),sample_size(i),'Replace',true);
        sim_dataB5 = datasample(M.D6_1m(M.CM==1),sample_size(i),'Replace',true);
        sim_dataA6 = datasample(M.mEDI_M(M.CM==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.mEDI_M(M.CM==1),sample_size(i),'Replace',true);
        sim_dataA7 = datasample(M.mEDI_A(M.CM==0),sample_size(i),'Replace',true);
        sim_dataB7 = datasample(M.mEDI_A(M.CM==1),sample_size(i),'Replace',true);
        sim_dataA8 = datasample(M.mEDI_B(M.CM==0),sample_size(i),'Replace',true);
        sim_dataB8 = datasample(M.mEDI_B(M.CM==1),sample_size(i),'Replace',true);
        noCM(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6);mean(sim_dataA7);mean(sim_dataA8)];
        CM(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6);mean(sim_dataB7);mean(sim_dataB8)];
        [~,pLightCM(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorCM(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDayCM(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningCM(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightCM(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pMorningCM(i,j)] = ttest2(sim_dataA6,sim_dataB6);
        [~,pAfternoonCM(i,j)] = ttest2(sim_dataA7,sim_dataB7);
        [~,pBedCM(i,j)] = ttest2(sim_dataA8,sim_dataB8);
    end
end
clear sim_data*

Plight = prctile(pLightCM,80,2);
Poutdoor = prctile(pOutdoorCM,80,2);
Pday = prctile(pDayCM,80,2);
Pevening = prctile(pEveningCM,80,2);
Pnight = prctile(pNightCM,80,2);
Pmorning = prctile(pMorningCM,80,2);
Pafternoon = prctile(pAfternoonCM,80,2);
pBed = prctile(pBedCM,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pmorning)
plot(sample_size,Pafternoon)
plot(sample_size,pBed)
title('not CM vs. CM')
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI morning','mEDI afternoon','mEDI evening','p = 0.05','p = 0.01'})


% Sleep impairment

for i = 1:length(sample_size)
    for j = 1:1000
        sim_dataA = datasample(M.Light(M.SlIbi==0),sample_size(i),'Replace',true);
        sim_dataB = datasample(M.Light(M.SlIbi==1),sample_size(i),'Replace',true);
        sim_dataA2 = datasample(M.B10_1000m(M.SlIbi==0),sample_size(i),'Replace',true);
        sim_dataB2 = datasample(M.B10_1000m(M.SlIbi==1),sample_size(i),'Replace',true);
        sim_dataA3 = datasample(M.B10_250m(M.SlIbi==0),sample_size(i),'Replace',true);
        sim_dataB3 = datasample(M.B10_250m(M.SlIbi==1),sample_size(i),'Replace',true);
        sim_dataA4 = datasample(M.E3_10m(M.SlIbi==0),sample_size(i),'Replace',true);
        sim_dataB4 = datasample(M.E3_10m(M.SlIbi==1),sample_size(i),'Replace',true);
        sim_dataA5 = datasample(M.D6_1m(M.SlIbi==0),sample_size(i),'Replace',true);
        sim_dataB5 = datasample(M.D6_1m(M.SlIbi==1),sample_size(i),'Replace',true);
        sim_dataA6 = datasample(M.mEDI_M(M.SlIbi==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.mEDI_M(M.SlIbi==1),sample_size(i),'Replace',true);
        sim_dataA7 = datasample(M.mEDI_A(M.SlIbi==0),sample_size(i),'Replace',true);
        sim_dataB7 = datasample(M.mEDI_A(M.SlIbi==1),sample_size(i),'Replace',true);
        sim_dataA8 = datasample(M.mEDI_B(M.SlIbi==0),sample_size(i),'Replace',true);
        sim_dataB8 = datasample(M.mEDI_B(M.SlIbi==1),sample_size(i),'Replace',true);
        noSlI(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6);mean(sim_dataA7);mean(sim_dataA8)];
        SlI(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6);mean(sim_dataB7);mean(sim_dataB8)];
        [~,pLightSlI(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorSlI(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDaySlI(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningSlI(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightSlI(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pMorningSlI(i,j)] = ttest2(sim_dataA6,sim_dataB6);
        [~,pAfternoonSlI(i,j)] = ttest2(sim_dataA7,sim_dataB7);
        [~,pBedSlI(i,j)] = ttest2(sim_dataA8,sim_dataB8);
    end
end
clear sim_data*

Plight = prctile(pLightSlI,80,2);
Poutdoor = prctile(pOutdoorSlI,80,2);
Pday = prctile(pDaySlI,80,2);
Pevening = prctile(pEveningSlI,80,2);
Pnight = prctile(pNightSlI,80,2);
Pmorning = prctile(pMorningSlI,80,2);
Pafternoon = prctile(pAfternoonSlI,80,2);
PBed = prctile(pBedSlI,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pmorning)
plot(sample_size,Pafternoon)
plot(sample_size,PBed)
title('low vs. high sleep impairment')
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI morning','mEDI afternoon','mEDI evening','p = 0.05','p = 0.01'})


% Sleep disturbance

for i = 1:length(sample_size)
    for j = 1:1000
        sim_dataA = datasample(M.Light(M.SlDbi==0),sample_size(i),'Replace',true);
        sim_dataB = datasample(M.Light(M.SlDbi==1),sample_size(i),'Replace',true);
        sim_dataA2 = datasample(M.B10_1000m(M.SlDbi==0),sample_size(i),'Replace',true);
        sim_dataB2 = datasample(M.B10_1000m(M.SlDbi==1),sample_size(i),'Replace',true);
        sim_dataA3 = datasample(M.B10_250m(M.SlDbi==0),sample_size(i),'Replace',true);
        sim_dataB3 = datasample(M.B10_250m(M.SlDbi==1),sample_size(i),'Replace',true);
        sim_dataA4 = datasample(M.E3_10m(M.SlDbi==0),sample_size(i),'Replace',true);
        sim_dataB4 = datasample(M.E3_10m(M.SlDbi==1),sample_size(i),'Replace',true);
        sim_dataA5 = datasample(M.D6_1m(M.SlDbi==0),sample_size(i),'Replace',true);
        sim_dataB5 = datasample(M.D6_1m(M.SlDbi==1),sample_size(i),'Replace',true);
        sim_dataA6 = datasample(M.mEDI_M(M.SlDbi==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.mEDI_M(M.SlDbi==1),sample_size(i),'Replace',true);
        sim_dataA7 = datasample(M.mEDI_A(M.SlDbi==0),sample_size(i),'Replace',true);
        sim_dataB7 = datasample(M.mEDI_A(M.SlDbi==1),sample_size(i),'Replace',true);
        sim_dataA8 = datasample(M.mEDI_B(M.SlDbi==0),sample_size(i),'Replace',true);
        sim_dataB8 = datasample(M.mEDI_B(M.SlDbi==1),sample_size(i),'Replace',true);
        noSlD(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6);mean(sim_dataA7);mean(sim_dataA8)];
        SlD(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6);mean(sim_dataB7);mean(sim_dataB8)];
        [~,pLightSlD(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorSlD(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDaySlD(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningSlD(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightSlD(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pMorningSlD(i,j)] = ttest2(sim_dataA6,sim_dataB6);
        [~,pAfternoonSlD(i,j)] = ttest2(sim_dataA7,sim_dataB7);
        [~,pBedSlD(i,j)] = ttest2(sim_dataA8,sim_dataB8);
    end
end
clear sim_data*

Plight = prctile(pLightSlD,80,2);
Poutdoor = prctile(pOutdoorSlD,80,2);
Pday = prctile(pDaySlD,80,2);
Pevening = prctile(pEveningSlD,80,2);
Pnight = prctile(pNightSlD,80,2);
Pmorning = prctile(pMorningSlD,80,2);
Pafternoon = prctile(pAfternoonSlD,80,2);
PBed = prctile(pBedSlD,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pmorning)
plot(sample_size,Pafternoon)
plot(sample_size,PBed)
title('low vs. high sleep disturbance')
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI morning','mEDI afternoon','mEDI evening','p = 0.05','p = 0.01'})


clear Poutdoor Pday Pevening Pnight Pmorning Pafternoon PBed
analysis_path = getpref('visualDiet','visualDietAnalysisPath');
save([analysis_path '/powerVD'])

figure
for x = 1:4
switch x
    case 1
        temp = squeeze(noCM(sample_size==75,:,:));
        temp2 = prctile(temp,[50 2.5 97.5]);
        temp3 = squeeze(CM(sample_size==75,:,:));
        temp4 = prctile(temp3,[50 2.5 97.5]);
        
        pl = 1:4:28;
        TITLE = {'Chronic Migraine'};
    case 2
        temp = squeeze(noDis(sample_size==75,:,:));
        temp2 = prctile(temp,[50 2.5 97.5]);
        temp3 = squeeze(Dis(sample_size==75,:,:));
        temp4 = prctile(temp3,[50 2.5 97.5]);
        pl = 2:4:28;
        TITLE = {'HA-related Disability'};
    case 3
        temp = squeeze(noVs(sample_size==75,:,:));
        temp2 = prctile(temp,[50 2.5 97.5]);
        temp3 = squeeze(Vs(sample_size==75,:,:));
        temp4 = prctile(temp3,[50 2.5 97.5]);
        pl = 3:4:28;
        TITLE = {'Visual Sensitivity'};
    case 4
        temp = squeeze(noSlI(sample_size==75,:,:));
        temp2 = prctile(temp,[50 2.5 97.5]);
        temp3 = squeeze(SlI(sample_size==75,:,:));
        temp4 = prctile(temp3,[50 2.5 97.5]);
        pl = 4:4:28;
        TITLE = {'Sleep Impairment'};
end
    subplot(7,4,pl(1))
    bar(1:2,[temp2(1,1) temp4(1,1)])
    hold on
    errorbar(1:2,[temp2(1,1) temp4(1,1)],abs(diff([temp2(1:2,1) temp4(1:2,1)])),abs(diff([temp2([1 3],1) temp4([1 3],1)])),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3]; ax.YLim = [2000 12000];
    ylabel('photopic luminous exposure')
    title(TITLE)

    subplot(7,4,pl(2))
    bar(1:2,[temp2(1,2) temp4(1,2)])
    hold on
    errorbar(1:2,[temp2(1,2) temp4(1,2)],abs(diff([temp2(1:2,2) temp4(1:2,2)])),abs(diff([temp2([1 3],2) temp4([1 3],2)])),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3]; ax.YLim = [20 80];
    ylabel('Time spent in outdoor light (min)')

    subplot(7,4,pl(3))
    bar(1:2,[temp2(1,3) temp4(1,3)])
    hold on
    errorbar(1:2,[temp2(1,3) temp4(1,3)],abs(diff([temp2(1:2,3) temp4(1:2,3)])),abs(diff([temp2([1 3],3) temp4([1 3],3)])),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3]; ax.YLim = [0.1 0.2];
    ylabel('% time spent in recommended daylight')

    subplot(7,4,pl(4))
    bar(1:2,[temp2(1,4) temp4(1,4)])
    hold on
    errorbar(1:2,[temp2(1,4) temp4(1,4)],abs(diff([temp2(1:2,4) temp4(1:2,4)])),abs(diff([temp2([1 3],4) temp4([1 3],4)])),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3]; ax.YLim = [0.6 0.9];
    ylabel('% time spent in recommended evening light')


    subplot(7,4,pl(5))
    bar(1:2,exp([temp2(1,6) temp4(1,6)]))
    hold on
    errorbar(1:2,exp([temp2(1,6) temp4(1,6)]),abs(diff(exp([temp2(1:2,6) temp4(1:2,6)]))),abs(diff(exp([temp2([1 3],6) temp4([1 3],6)]))),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3]; ax.YLim = [0.01 1]; ax.YScale = 'log';
    ylabel('mEDI morning')

    subplot(7,4,pl(6))
    bar(1:2,exp([temp2(1,7) temp4(1,7)]))
    hold on
    errorbar(1:2,exp([temp2(1,7) temp4(1,7)]),abs(diff(exp([temp2(1:2,7) temp4(1:2,7)]))),abs(diff(exp([temp2([1 3],7) temp4([1 3],7)]))),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3]; ax.YLim = [1 200]; ax.YScale = 'log';
    ylabel('mEDI afternoon')

    subplot(7,4,pl(7))
    bar(1:2,exp([temp2(1,8) temp4(1,8)]))
    hold on
    errorbar(1:2,exp([temp2(1,8) temp4(1,8)]),abs(diff(exp([temp2(1:2,8) temp4(1:2,8)]))),abs(diff(exp([temp2([1 3],8) temp4([1 3],8)]))),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3]; ax.YLim = [0.01 1]; ax.YScale = 'log';
    ylabel('mEDI evening')

end
clear temp*


Power = 0.1:0.1:100;
figure
for x = 1:4
switch x
    case 1
        AA = sort(pLightCM,2);
        BB = sort(pOutdoorCM,2);
        CC = sort(pDayCM,2);
        DD = sort(pEveningCM,2);
        EE = sort(pMorningCM,2);
        FF = sort(pAfternoonCM,2);
        GG = sort(pBedCM,2);
        pl = 1:4:28;
        TITLE = {'Chronic Migraine'};
    case 2
        AA = sort(pLightDis,2);
        BB = sort(pOutdoorDis,2);
        CC = sort(pDayDis,2);
        DD = sort(pEveningDis,2);
        EE = sort(pMorningDis,2);
        FF = sort(pAfternoonDis,2);
        GG = sort(pBedDis,2);
        pl = 2:4:28;
        TITLE = {'HA-related Disability'};
    case 3
        AA = sort(pLightVs,2);
        BB = sort(pOutdoorVs,2);
        CC = sort(pDayVs,2);
        DD = sort(pEveningVs,2);
        EE = sort(pMorningVs,2);
        FF = sort(pAfternoonVs,2);
        GG = sort(pBedVs,2);
        pl = 3:4:28;
        TITLE = {'Visual Sensitivity'};
    case 4
        AA = sort(pLightSlI,2);
        BB = sort(pOutdoorSlI,2);
        CC = sort(pDaySlI,2);
        DD = sort(pEveningSlI,2);
        EE = sort(pMorningSlI,2);
        FF = sort(pAfternoonSlI,2);
        GG = sort(pBedSlI,2);
        pl = 4:4:28;
        TITLE = {'Sleep Impairment'};
end
        for y = 1:length(sample_size)
            temptemp = Power(:,AA(y,:)<0.05);
            if ~isempty(temptemp)
                Apower(:,y) = max(temptemp);
            else
                Apower(:,y) = 0;
            end
            temptemp = Power(:,BB(y,:)<0.05);
            if ~isempty(temptemp)
                Bpower(:,y) = max(temptemp);
            else
                Bpower(:,y) = 0;
            end
            temptemp = Power(:,CC(y,:)<0.05);
            if ~isempty(temptemp)
                Cpower(:,y) = max(temptemp);
            else
                Cpower(:,y) = 0;
            end
            temptemp = Power(:,DD(y,:)<0.05);
            if ~isempty(temptemp)
                Dpower(:,y) = max(temptemp);
            else
                Dpower(:,y) = 0;
            end
            temptemp = Power(:,EE(y,:)<0.05);
            if ~isempty(temptemp)
                Epower(:,y) = max(temptemp);
            else
                Epower(:,y) = 0;
            end
            temptemp = Power(:,FF(y,:)<0.05);
            if ~isempty(temptemp)
                Fpower(:,y) = max(temptemp);
            else
                Fpower(:,y) = 0;
            end
            temptemp = Power(:,GG(y,:)<0.05);
            if ~isempty(temptemp)
                Gpower(:,y) = max(temptemp);
            else
                Gpower(:,y) = 0;
            end
        end

    subplot(7,4,pl(1))
    hold on
    plot(sample_size,Apower,'-k')
    temp = sample_size(Apower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('photopic luminous exposure')
    title(TITLE)

    subplot(7,4,pl(2))
    hold on
    plot(sample_size,Bpower,'-k')
    temp = sample_size(Bpower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('Time spent in outdoor light (min)')

    subplot(7,4,pl(3))
    hold on
    plot(sample_size,Cpower,'-k')
    temp = sample_size(Cpower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('% time spent in recommended daylight')

    subplot(7,4,pl(4))
    hold on
    plot(sample_size,Dpower,'-k')
    temp = sample_size(Dpower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('% time spent in recommended evening light')


    subplot(7,4,pl(5))
    hold on
    plot(sample_size,Epower,'-k')
    temp = sample_size(Epower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('mEDI morning')

    subplot(7,4,pl(6))
    hold on
    plot(sample_size,Fpower,'-k')
    temp = sample_size(Fpower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('mEDI afternoon')

    subplot(7,4,pl(7))
    hold on
    plot(sample_size,Gpower,'-k')
    temp = sample_size(Gpower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('mEDI evening')

end


