% Actlumus data analysis
% Some light metrics based on Guidolin et al. "Protocol for a prospective, multicentre, 
% cross-sectional cohort study to assess personal light exposure." medRxiv (2024): 2024-02.

data_path = getpref('visualDiet','visualDietDataPath');
load([data_path '/pilotVDanalysis'],'M','T','subject_data')

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
        sim_dataA6 = datasample(M.LightShift(M.FopBi==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.LightShift(M.FopBi==1),sample_size(i),'Replace',true);
        noFOP(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6)];
        FOP(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6)];
        [~,pLightFOP(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorFOP(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDayFOP(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningFOP(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightFOP(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pShiftFOP(i,j)] = ttest2(sim_dataA6,sim_dataB6);
    end
end
clear sim_data*

Plight = prctile(pLightFOP,80,2);
Poutdoor = prctile(pOutdoorFOP,80,2);
Pday = prctile(pDayFOP,80,2);
Pevening = prctile(pEveningFOP,80,2);
Pnight = prctile(pNightFOP,80,2);
Pshift = prctile(pShiftFOP,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pshift)
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
title('low vs. high FOP')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI shift','p = 0.05','p = 0.01'})

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
        sim_dataA6 = datasample(M.LightShift(M.DisBi==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.LightShift(M.DisBi==1),sample_size(i),'Replace',true);
        noDis(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6)];
        Dis(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6)];
        [~,pLightDis(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorDis(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDayDis(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningDis(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightDis(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pShiftDis(i,j)] = ttest2(sim_dataA6,sim_dataB6);
    end
end
clear sim_data*

Plight = prctile(pLightDis,80,2);
Poutdoor = prctile(pOutdoorDis,80,2);
Pday = prctile(pDayDis,80,2);
Pevening = prctile(pEveningDis,80,2);
Pnight = prctile(pNightDis,80,2);
Pshift = prctile(pShiftDis,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pshift)
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
title('low vs. high Disability')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI shift','p = 0.05','p = 0.01'})

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
        sim_dataA6 = datasample(M.LightShift(M.VsBi==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.LightShift(M.VsBi==1),sample_size(i),'Replace',true);
        noVs(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6)];
        Vs(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6)];
        [~,pLightVs(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorVs(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDayVs(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningVs(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightVs(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pShiftVs(i,j)] = ttest2(sim_dataA6,sim_dataB6);
    end
end
clear sim_data*

Plight = prctile(pLightVs,80,2);
Poutdoor = prctile(pOutdoorVs,80,2);
Pday = prctile(pDayVs,80,2);
Pevening = prctile(pEveningVs,80,2);
Pnight = prctile(pNightVs,80,2);
Pshift = prctile(pShiftVs,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pshift)
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
title('low vs. high VS')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI shift','p = 0.05','p = 0.01'})



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
        sim_dataA6 = datasample(M.LightShift(M.CM==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.LightShift(M.CM==1),sample_size(i),'Replace',true);
        noCM(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6)];
        CM(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6)];
        [~,pLightCM(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorCM(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDayCM(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningCM(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightCM(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pShiftCM(i,j)] = ttest2(sim_dataA6,sim_dataB6);
    end
end
clear sim_data*

Plight = prctile(pLightCM,80,2);
Poutdoor = prctile(pOutdoorCM,80,2);
Pday = prctile(pDayCM,80,2);
Pevening = prctile(pEveningCM,80,2);
Pnight = prctile(pNightCM,80,2);
Pshift = prctile(pShiftCM,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pshift)
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
title('CM vs. not CM')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI shift','p = 0.05','p = 0.01'})


figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pshift)
title('not CM vs. CM')
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI Shift','p = 0.05','p = 0.01'})


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
        sim_dataA6 = datasample(M.LightShift(M.SlIbi==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.LightShift(M.SlIbi==1),sample_size(i),'Replace',true);
        noSlI(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6)];
        SlI(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6)];
        [~,pLightSlI(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorSlI(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDaySlI(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningSlI(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightSlI(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pShiftSlI(i,j)] = ttest2(sim_dataA6,sim_dataB6);
    end
end
clear sim_data*

Plight = prctile(pLightSlI,80,2);
Poutdoor = prctile(pOutdoorSlI,80,2);
Pday = prctile(pDaySlI,80,2);
Pevening = prctile(pEveningSlI,80,2);
Pnight = prctile(pNightSlI,80,2);
Pshift = prctile(pShiftSlI,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pshift)
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
title('low vs. high Sleep impairment')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI shift','p = 0.05','p = 0.01'})


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
        sim_dataA6 = datasample(M.LightShift(M.SlDbi==0),sample_size(i),'Replace',true);
        sim_dataB6 = datasample(M.LightShift(M.SlDbi==1),sample_size(i),'Replace',true);
        noSlD(i,j,:) = [mean(sim_dataA);mean(sim_dataA2);mean(sim_dataA3);mean(sim_dataA4);mean(sim_dataA5);...
            mean(sim_dataA6)];
        SlD(i,j,:) = [mean(sim_dataB);mean(sim_dataB2);mean(sim_dataB3);mean(sim_dataB4);mean(sim_dataB5);...
            mean(sim_dataB6)];
        [~,pLightSlD(i,j)] = ttest2(sim_dataA,sim_dataB);
        [~,pOutdoorSlD(i,j)] = ttest2(sim_dataA2,sim_dataB2);
        [~,pDaySlD(i,j)] = ttest2(sim_dataA3,sim_dataB3);
        [~,pEveningSlD(i,j)] = ttest2(sim_dataA4,sim_dataB4);
        [~,pNightSlD(i,j)] = ttest2(sim_dataA5,sim_dataB5);
        [~,pShiftSlD(i,j)] = ttest2(sim_dataA6,sim_dataB6);
    end
end
clear sim_data*

Plight = prctile(pLightSlD,80,2);
Poutdoor = prctile(pOutdoorSlD,80,2);
Pday = prctile(pDaySlD,80,2);
Pevening = prctile(pEveningSlD,80,2);
Pnight = prctile(pNightSlD,80,2);
Pshift = prctile(pShiftFOP,80,2);

figure
plot(sample_size,Plight)
hold on
plot(sample_size,Poutdoor)
plot(sample_size,Pday)
plot(sample_size,Pevening)
plot(sample_size,Pnight)
plot(sample_size,Pshift)
plot([0 sample_size(end)],[0.05 0.05],'--k')
plot([0 sample_size(end)],[0.01 0.01],'--k')
title('low vs. high Sleep Disturbance')
legend({'photopic luminous exposure','time outdoors','%mEDI day','%mEDI evening','%mEDI night','mEDI shift','p = 0.05','p = 0.01'})


clear Poutdoor Pday Pevening Pnight Pshift
analysis_path = getpref('visualDiet','visualDietAnalysisPath');
save([analysis_path '/powerVD'])

figure
for x = 1:6
switch x
    case 1
        temp = squeeze(noCM(sample_size==75,:,:));
        temp2 = prctile(temp,[50 2.5 97.5]);
        temp3 = squeeze(CM(sample_size==75,:,:));
        temp4 = prctile(temp3,[50 2.5 97.5]);
        pl = 1:6:36;
        TITLE = {'Chronic Migraine'};
    case 2
        temp = squeeze(noDis(sample_size==75,:,:));
        temp2 = prctile(temp,[50 2.5 97.5]);
        temp3 = squeeze(Dis(sample_size==75,:,:));
        temp4 = prctile(temp3,[50 2.5 97.5]);
        pl = 2:6:36;
        TITLE = {'HA-related Disability'};
    case 3
        temp = squeeze(noVs(sample_size==75,:,:));
        temp2 = prctile(temp,[50 2.5 97.5]);
        temp3 = squeeze(Vs(sample_size==75,:,:));
        temp4 = prctile(temp3,[50 2.5 97.5]);
        pl = 3:6:36;
        TITLE = {'Visual Sensitivity'};
    case 4
        temp = squeeze(noFOP(sample_size==75,:,:));
        temp2 = prctile(temp,[50 2.5 97.5]);
        temp3 = squeeze(FOP(sample_size==75,:,:));
        temp4 = prctile(temp3,[50 2.5 97.5]);
        pl = 4:6:36;
        TITLE = {'Fear of Pain'};
    case 5
        temp = squeeze(noSlI(sample_size==75,:,:));
        temp2 = prctile(temp,[50 2.5 97.5]);
        temp3 = squeeze(SlI(sample_size==75,:,:));
        temp4 = prctile(temp3,[50 2.5 97.5]);
        pl = 5:6:36;
        TITLE = {'Sleep Impairment'};
    case 6
        temp = squeeze(noSlD(sample_size==75,:,:));
        temp2 = prctile(temp,[50 2.5 97.5]);
        temp3 = squeeze(SlD(sample_size==75,:,:));
        temp4 = prctile(temp3,[50 2.5 97.5]);
        pl = 6:6:36;
        TITLE = {'Sleep Disturbance'};
end
    subplot(6,6,pl(1))
    bar(1:2,[temp2(1,1) temp4(1,1)])
    hold on
    errorbar(1:2,[temp2(1,1) temp4(1,1)],abs(diff([temp2(1:2,1) temp4(1:2,1)])),abs(diff([temp2([1 3],1) temp4([1 3],1)])),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3]; ax.YLim = [2000 12000];
    ylabel('photopic luminous exposure')
    title(TITLE)

    subplot(6,6,pl(2))
    bar(1:2,[temp2(1,2) temp4(1,2)])
    hold on
    errorbar(1:2,[temp2(1,2) temp4(1,2)],abs(diff([temp2(1:2,2) temp4(1:2,2)])),abs(diff([temp2([1 3],2) temp4([1 3],2)])),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3]; ax.YLim = [20 80];
    ylabel('Time spent in outdoor light (min)')

    subplot(6,6,pl(3))
    bar(1:2,[temp2(1,3) temp4(1,3)])
    hold on
    errorbar(1:2,[temp2(1,3) temp4(1,3)],abs(diff([temp2(1:2,3) temp4(1:2,3)])),abs(diff([temp2([1 3],3) temp4([1 3],3)])),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3]; ax.YLim = [0.1 0.2];
    ylabel('% time spent in recommended daylight')

    subplot(6,6,pl(4))
    bar(1:2,[temp2(1,4) temp4(1,4)])
    hold on
    errorbar(1:2,[temp2(1,4) temp4(1,4)],abs(diff([temp2(1:2,4) temp4(1:2,4)])),abs(diff([temp2([1 3],4) temp4([1 3],4)])),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3]; ax.YLim = [0.6 0.9];
    ylabel('% time spent in recommended evening light')

    subplot(6,6,pl(5))
    bar(1:2,[temp2(1,5) temp4(1,5)])
    hold on
    errorbar(1:2,[temp2(1,5) temp4(1,5)],abs(diff([temp2(1:2,5) temp4(1:2,5)])),abs(diff([temp2([1 3],5) temp4([1 3],5)])),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3];
    ylabel('% time spent in recommended night light')


    subplot(6,6,pl(6))
    bar(1:2,[temp2(1,6) temp4(1,6)])
    hold on
    errorbar(1:2,[temp2(1,6) temp4(1,6)],abs(diff([temp2(1:2,6) temp4(1:2,6)])),abs(diff([temp2([1 3],6) temp4([1 3],6)])),'+')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 3];
    ylabel('mEDI Shift')

end
clear temp*


Power = 0.1:0.1:100;
figure
for x = 1:6
switch x
    case 1
        AA = sort(pLightCM,2);
        BB = sort(pOutdoorCM,2);
        CC = sort(pDayCM,2);
        DD = sort(pEveningCM,2);
        EE = sort(pNightCM,2);
        FF = sort(pShiftCM,2);
        pl = 1:6:36;
        TITLE = {'Chronic Migraine'};
    case 2
        AA = sort(pLightDis,2);
        BB = sort(pOutdoorDis,2);
        CC = sort(pDayDis,2);
        DD = sort(pEveningDis,2);
        EE = sort(pNightDis,2);
        FF = sort(pShiftDis,2);
        pl = 2:6:36;
        TITLE = {'HA-related Disability'};
    case 3
        AA = sort(pLightVs,2);
        BB = sort(pOutdoorVs,2);
        CC = sort(pDayVs,2);
        DD = sort(pEveningVs,2);
        EE = sort(pNightVs,2);
        FF = sort(pShiftVs,2);
        pl = 3:6:36;
        TITLE = {'Visual Sensitivity'};
    case 4
        AA = sort(pLightFOP,2);
        BB = sort(pOutdoorFOP,2);
        CC = sort(pDayFOP,2);
        DD = sort(pEveningFOP,2);
        EE = sort(pNightFOP,2);
        FF = sort(pShiftFOP,2);
        pl = 4:6:36;
        TITLE = {'Fear of Pain'};
    case 5
        AA = sort(pLightSlI,2);
        BB = sort(pOutdoorSlI,2);
        CC = sort(pDaySlI,2);
        DD = sort(pEveningSlI,2);
        EE = sort(pNightSlI,2);
        FF = sort(pShiftSlI,2);
        pl = 5:6:36;
        TITLE = {'Sleep Impairment'};
    case 6
        AA = sort(pLightSlD,2);
        BB = sort(pOutdoorSlD,2);
        CC = sort(pDaySlD,2);
        DD = sort(pEveningSlD,2);
        EE = sort(pNightSlD,2);
        FF = sort(pShiftSlD,2);
        pl = 6:6:36;
        TITLE = {'Sleep Disturbance'};
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
        end

    subplot(6,6,pl(1))
    hold on
    plot(sample_size,Apower,'-k')
    temp = sample_size(Apower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('photopic luminous exposure')
    title(TITLE)

    subplot(6,6,pl(2))
    hold on
    plot(sample_size,Bpower,'-k')
    temp = sample_size(Bpower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('Time spent in outdoor light (min)')

    subplot(6,6,pl(3))
    hold on
    plot(sample_size,Cpower,'-k')
    temp = sample_size(Cpower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('% time spent in recommended daylight')

    subplot(6,6,pl(4))
    hold on
    plot(sample_size,Dpower,'-k')
    temp = sample_size(Dpower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('% time spent in recommended evening light')

    subplot(6,6,pl(5))
    hold on
    plot(sample_size,Epower,'-k')
    temp = sample_size(Epower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('% time spent in recommended night light')


    subplot(6,6,pl(6))
    hold on
    plot(sample_size,Fpower,'-k')
    temp = sample_size(Fpower>=80);
    if ~isempty(temp)
        plot(min(temp),80,'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [5 75]; ax.YLim = [0 100];
    ylabel('mEDI Shift')

end


