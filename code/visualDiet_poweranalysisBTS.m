% Actlumus data analysis
% Some light metrics based on Guidolin et al. "Protocol for a prospective, multicentre, 
% cross-sectional cohort study to assess personal light exposure." medRxiv (2024): 2024-02.

data_path = getpref('visualDiet','visualDietDataPath');
load([data_path '/pilotVDanalysis'],'M','T','subject_data')

participants = unique(M.record_id);

%% Power Analysis

sample_size = 1:75;

% CM
a1 = mean(M.Light(M.CM==0)); b1 = mean(M.Light(M.CM==1)); sd1 = std(M.Light(M.CM==0));
a2 = mean(M.B10_1000m(M.CM==0)); b2 = mean(M.B10_1000m(M.CM==1)); sd2 = std(M.B10_1000m(M.CM==0));
a3 = mean(M.B10_250m(M.CM==0)); b3 = mean(M.B10_250m(M.CM==1)); sd3 = std(M.B10_250m(M.CM==0));
a4 = mean(M.E3_10m(M.CM==0)); b4 = mean(M.E3_10m(M.CM==1)); sd4 = std(M.E3_10m(M.CM==0));
a5 = mean(M.D6_1m(M.CM==0)); b5 = mean(M.D6_1m(M.CM==1)); sd5 = std(M.D6_1m(M.CM==0));
a6 = mean(M.LightShift(M.CM==0)); b6 = mean(M.LightShift(M.CM==1)); sd6 = std(M.LightShift(M.CM==0));

for i = 1:length(sample_size)
    pwrout_CM(i,1) = sampsizepwr('t2',[a1 sd1],b1,[],sample_size(i));
    pwrout_CM(i,2) = sampsizepwr('t2',[a2 sd2],b2,[],sample_size(i));
    pwrout_CM(i,3) = sampsizepwr('t2',[a3 sd3],b3,[],sample_size(i));
    pwrout_CM(i,4) = sampsizepwr('t2',[a4 sd4],b4,[],sample_size(i));
    pwrout_CM(i,5) = sampsizepwr('t2',[a5 sd5],b5,[],sample_size(i));
    pwrout_CM(i,6) = sampsizepwr('t2',[a6 sd6],b6,[],sample_size(i));
end

% Disability
a1 = mean(M.Light(M.DisBi==0)); b1 = mean(M.Light(M.DisBi==1)); sd1 = std(M.Light(M.DisBi==0));
a2 = mean(M.B10_1000m(M.DisBi==0)); b2 = mean(M.B10_1000m(M.DisBi==1)); sd2 = std(M.B10_1000m(M.DisBi==0));
a3 = mean(M.B10_250m(M.DisBi==0)); b3 = mean(M.B10_250m(M.DisBi==1)); sd3 = std(M.B10_250m(M.DisBi==0));
a4 = mean(M.E3_10m(M.DisBi==0)); b4 = mean(M.E3_10m(M.DisBi==1)); sd4 = std(M.E3_10m(M.DisBi==0));
a5 = mean(M.D6_1m(M.DisBi==0)); b5 = mean(M.D6_1m(M.DisBi==1)); sd5 = std(M.D6_1m(M.DisBi==0));
a6 = mean(M.LightShift(M.DisBi==0)); b6 = mean(M.LightShift(M.DisBi==1)); sd6 = std(M.LightShift(M.DisBi==0));

for i = 1:length(sample_size)
    pwrout_Dis(i,1) = sampsizepwr('t2',[a1 sd1],b1,[],sample_size(i));
    pwrout_Dis(i,2) = sampsizepwr('t2',[a2 sd2],b2,[],sample_size(i));
    pwrout_Dis(i,3) = sampsizepwr('t2',[a3 sd3],b3,[],sample_size(i));
    pwrout_Dis(i,4) = sampsizepwr('t2',[a4 sd4],b4,[],sample_size(i));
    pwrout_Dis(i,5) = sampsizepwr('t2',[a5 sd5],b5,[],sample_size(i));
    pwrout_Dis(i,6) = sampsizepwr('t2',[a6 sd6],b6,[],sample_size(i));
end

% Visual sensitivity
a1 = mean(M.Light(M.VsBi==0)); b1 = mean(M.Light(M.VsBi==1)); sd1 = std(M.Light(M.VsBi==0));
a2 = mean(M.B10_1000m(M.VsBi==0)); b2 = mean(M.B10_1000m(M.VsBi==1)); sd2 = std(M.B10_1000m(M.VsBi==0));
a3 = mean(M.B10_250m(M.VsBi==0)); b3 = mean(M.B10_250m(M.VsBi==1)); sd3 = std(M.B10_250m(M.VsBi==0));
a4 = mean(M.E3_10m(M.VsBi==0)); b4 = mean(M.E3_10m(M.VsBi==1)); sd4 = std(M.E3_10m(M.VsBi==0));
a5 = mean(M.D6_1m(M.VsBi==0)); b5 = mean(M.D6_1m(M.VsBi==1)); sd5 = std(M.D6_1m(M.VsBi==0));
a6 = mean(M.LightShift(M.VsBi==0)); b6 = mean(M.LightShift(M.VsBi==1)); sd6 = std(M.LightShift(M.VsBi==0));

for i = 1:length(sample_size)
    pwrout_Vs(i,1) = sampsizepwr('t2',[a1 sd1],b1,[],sample_size(i));
    pwrout_Vs(i,2) = sampsizepwr('t2',[a2 sd2],b2,[],sample_size(i));
    pwrout_Vs(i,3) = sampsizepwr('t2',[a3 sd3],b3,[],sample_size(i));
    pwrout_Vs(i,4) = sampsizepwr('t2',[a4 sd4],b4,[],sample_size(i));
    pwrout_Vs(i,5) = sampsizepwr('t2',[a5 sd5],b5,[],sample_size(i));
    pwrout_Vs(i,6) = sampsizepwr('t2',[a6 sd6],b6,[],sample_size(i));
end

% Fear of Pain
a1 = mean(M.Light(M.FopBi==0)); b1 = mean(M.Light(M.FopBi==1)); sd1 = std(M.Light(M.FopBi==0));
a2 = mean(M.B10_1000m(M.FopBi==0)); b2 = mean(M.B10_1000m(M.FopBi==1)); sd2 = std(M.B10_1000m(M.FopBi==0));
a3 = mean(M.B10_250m(M.FopBi==0)); b3 = mean(M.B10_250m(M.FopBi==1)); sd3 = std(M.B10_250m(M.FopBi==0));
a4 = mean(M.E3_10m(M.FopBi==0)); b4 = mean(M.E3_10m(M.FopBi==1)); sd4 = std(M.E3_10m(M.FopBi==0));
a5 = mean(M.D6_1m(M.FopBi==0)); b5 = mean(M.D6_1m(M.FopBi==1)); sd5 = std(M.D6_1m(M.FopBi==0));
a6 = mean(M.LightShift(M.FopBi==0)); b6 = mean(M.LightShift(M.FopBi==1)); sd6 = std(M.LightShift(M.FopBi==0));

for i = 1:length(sample_size)
    pwrout_Fop(i,1) = sampsizepwr('t2',[a1 sd1],b1,[],sample_size(i));
    pwrout_Fop(i,2) = sampsizepwr('t2',[a2 sd2],b2,[],sample_size(i));
    pwrout_Fop(i,3) = sampsizepwr('t2',[a3 sd3],b3,[],sample_size(i));
    pwrout_Fop(i,4) = sampsizepwr('t2',[a4 sd4],b4,[],sample_size(i));
    pwrout_Fop(i,5) = sampsizepwr('t2',[a5 sd5],b5,[],sample_size(i));
    pwrout_Fop(i,6) = sampsizepwr('t2',[a6 sd6],b6,[],sample_size(i));
end

% Sleep Impairment
a1 = mean(M.Light(M.SlIbi==0)); b1 = mean(M.Light(M.SlIbi==1)); sd1 = std(M.Light(M.SlIbi==0));
a2 = mean(M.B10_1000m(M.SlIbi==0)); b2 = mean(M.B10_1000m(M.SlIbi==1)); sd2 = std(M.B10_1000m(M.SlIbi==0));
a3 = mean(M.B10_250m(M.SlIbi==0)); b3 = mean(M.B10_250m(M.SlIbi==1)); sd3 = std(M.B10_250m(M.SlIbi==0));
a4 = mean(M.E3_10m(M.SlIbi==0)); b4 = mean(M.E3_10m(M.SlIbi==1)); sd4 = std(M.E3_10m(M.SlIbi==0));
a5 = mean(M.D6_1m(M.SlIbi==0)); b5 = mean(M.D6_1m(M.SlIbi==1)); sd5 = std(M.D6_1m(M.SlIbi==0));
a6 = mean(M.LightShift(M.SlIbi==0)); b6 = mean(M.LightShift(M.SlIbi==1)); sd6 = std(M.LightShift(M.SlIbi==0));

for i = 1:length(sample_size)
    pwrout_SleepI(i,1) = sampsizepwr('t2',[a1 sd1],b1,[],sample_size(i));
    pwrout_SleepI(i,2) = sampsizepwr('t2',[a2 sd2],b2,[],sample_size(i));
    pwrout_SleepI(i,3) = sampsizepwr('t2',[a3 sd3],b3,[],sample_size(i));
    pwrout_SleepI(i,4) = sampsizepwr('t2',[a4 sd4],b4,[],sample_size(i));
    pwrout_SleepI(i,5) = sampsizepwr('t2',[a5 sd5],b5,[],sample_size(i));
    pwrout_SleepI(i,6) = sampsizepwr('t2',[a6 sd6],b6,[],sample_size(i));
end

% Sleep Disturbance
a1 = mean(M.Light(M.SlDbi==0)); b1 = mean(M.Light(M.SlDbi==1)); sd1 = std(M.Light(M.SlDbi==0));
a2 = mean(M.B10_1000m(M.SlDbi==0)); b2 = mean(M.B10_1000m(M.SlDbi==1)); sd2 = std(M.B10_1000m(M.SlDbi==0));
a3 = mean(M.B10_250m(M.SlDbi==0)); b3 = mean(M.B10_250m(M.SlDbi==1)); sd3 = std(M.B10_250m(M.SlDbi==0));
a4 = mean(M.E3_10m(M.SlDbi==0)); b4 = mean(M.E3_10m(M.SlDbi==1)); sd4 = std(M.E3_10m(M.SlDbi==0));
a5 = mean(M.D6_1m(M.SlDbi==0)); b5 = mean(M.D6_1m(M.SlDbi==1)); sd5 = std(M.D6_1m(M.SlDbi==0));
a6 = mean(M.LightShift(M.SlDbi==0)); b6 = mean(M.LightShift(M.SlDbi==1)); sd6 = std(M.LightShift(M.SlDbi==0));

for i = 1:length(sample_size)
    pwrout_SleepD(i,1) = sampsizepwr('t2',[a1 sd1],b1,[],sample_size(i));
    pwrout_SleepD(i,2) = sampsizepwr('t2',[a2 sd2],b2,[],sample_size(i));
    pwrout_SleepD(i,3) = sampsizepwr('t2',[a3 sd3],b3,[],sample_size(i));
    pwrout_SleepD(i,4) = sampsizepwr('t2',[a4 sd4],b4,[],sample_size(i));
    pwrout_SleepD(i,5) = sampsizepwr('t2',[a5 sd5],b5,[],sample_size(i));
    pwrout_SleepD(i,6) = sampsizepwr('t2',[a6 sd6],b6,[],sample_size(i));
end

figure

pl = [1:6:36;2:6:36;3:6:36;4:6:36;5:6:36;6:6:36];
titles = {'photopic luminous exposure','Time spent in bright light','%time >250 daylight',...
    '%time <10 evening','%time <1 night','mEDI shift'};
for x = 1:size(pwrout_CM,2)
    subplot(6,6,pl(x,1))
    plot(sample_size,pwrout_CM(:,x),'k')
    hold on
    temp = sample_size(:,pwrout_CM(:,x)>0.80);
    if ~isempty(temp)
        plot(min(temp),pwrout_CM(sample_size==min(temp),x),'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [1 75]; ax.YLim = [0 1];
    title(titles(:,x))
    if x==1
        ylabel('Chronic migraine')
    end

    subplot(6,6,pl(x,2))
    plot(sample_size,pwrout_Dis(:,x),'k')
    hold on
    temp = sample_size(:,pwrout_Dis(:,x)>0.80);
    if ~isempty(temp)
        plot(min(temp),pwrout_Dis(sample_size==min(temp),x),'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [1 75]; ax.YLim = [0 1];
    if x==1
        ylabel('Headache disability')
    end

    subplot(6,6,pl(x,3))
    plot(sample_size,pwrout_Vs(:,x),'k')
    hold on
    temp = sample_size(:,pwrout_Vs(:,x)>0.80);
    if ~isempty(temp)
        plot(min(temp),pwrout_Vs(sample_size==min(temp),x),'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [1 75]; ax.YLim = [0 1];
    if x==1
        ylabel('Visual sensitivity')
    end

    subplot(6,6,pl(x,4))
    plot(sample_size,pwrout_Fop(:,x),'k')
    hold on
    temp = sample_size(:,pwrout_Fop(:,x)>0.80);
    if ~isempty(temp)
        plot(min(temp),pwrout_Fop(sample_size==min(temp),x),'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [1 75]; ax.YLim = [0 1];
    if x==1
        ylabel('Fear of pain')
    end

    subplot(6,6,pl(x,5))
    plot(sample_size,pwrout_SleepI(:,x),'k')
    hold on
    temp = sample_size(:,pwrout_SleepI(:,x)>0.80);
    if ~isempty(temp)
        plot(min(temp),pwrout_SleepI(sample_size==min(temp),x),'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [1 75]; ax.YLim = [0 1];
    if x==1
        ylabel('Sleep impairment')
    end

    subplot(6,6,pl(x,6))
    plot(sample_size,pwrout_SleepD(:,x),'k')
    hold on
    temp = sample_size(:,pwrout_SleepD(:,x)>0.80);
    if ~isempty(temp)
        plot(min(temp),pwrout_SleepD(sample_size==min(temp),x),'or')
    end
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [1 75]; ax.YLim = [0 1];
    if x==1
        ylabel('Sleep disturbance')
    end
end