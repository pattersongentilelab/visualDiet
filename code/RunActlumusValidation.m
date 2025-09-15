% Organize actlumus validation dataset
data_path = getpref('visualDiet','visualDietDataPath');
addpath '/Users/pattersonc/Documents/MATLAB/commonFx'

load([data_path '/Actlumus/Actlumus validation/mdlBin1cpg2.mat'],'mdlLR','actlumusAll')

bin_size = 0;
model = 0; % 0 = logistic regression, 1 = SVM

% select dataset
validateData = actlumusAll(actlumusAll.testData==0 & ~isundefined(actlumusAll.wearLabel),:);

switch model
    case 0
        Mdl = mdlLR;
    case 1
        Mdl = Mdlsvm;
end

trueLabel = validateData.wearLabel;
[predLabel,scores] = predict(Mdl,validateData);
rocObj = rocmetrics(trueLabel,scores,Mdl.ClassNames);%,'NumBootstraps', 100);
op = modelOperatingPoint(rocObj);
thrshW = op.Threshold(3);
thrshNw = op.Threshold(2);
thrshN = op.Threshold(1);
figure
plot(rocObj)%,'ShowConfidenceIntervals',true)

CM = confusionmat(trueLabel,predLabel);
figure
confusionchart(CM)

ss = NaN*ones(size(CM,1),1);
for i = 1:size(CM,1)
    TP = CM(i,i);
    FP = sum(CM(:,i))-TP;
    FN = sum(CM(i,:))-TP;
    TN = sum(sum(CM(:,:)))-(TP+FP+FN);
    ss(i,1) = TP/(TP+FN);
    ss(i,2) = TN/(TN+FP);
end

SS = (CM(1,1) + CM(2,2) + CM(3,3))/sum(sum(CM(:,:)));

testers = unique(validateData.tester);

save([data_path '/Actlumus/Actlumus validation/mdlValidateBin1cpg2.mat'],'rocObj','ss','SS')
%% run model on participants with migraine
load([data_path 'VDS.mat'])

participants = fieldnames(headache_diary);
headache_diary = struct2cell(headache_diary);
actlumus = struct2cell(actlumus);

prctDay = NaN*ones(length(participants),7);
prctNight = NaN*ones(length(participants),7);

for i = 1:length(participants)
    vd = actlumus{i};
    hd = headache_diary{i};
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

    vd = vd(ismember(vd.day,[hd.day;hd.day(end)+1]),:);
    vd.daytime = minute(vd.TIME);

    vd.participant = categorical(cellstr(repmat(participants{i},[height(vd),1])));
    vd.outdoor = zeros(height(vd),1);
    vd.outdoor(vd.LIGHT>1000) = 1;
    vd.hiIR = zeros(height(vd),1);
    vd.hiIR(vd.IRphoto>0.0008) = 1;
    
    vd.hang = zeros(height(vd),1);
    vd.up = zeros(height(vd),1);
    vd.down = zeros(height(vd),1);
    vd.move = zeros(height(vd),1);
    vd.dark = zeros(height(vd),1);

    for x = floor((bin_size/2))+1:height(vd)-floor((bin_size/2))
        epoch = vd(x-floor((bin_size/2)):x+floor((bin_size/2)),:);
    
        if mode(epoch.ORIENTATION)<32
            vd.up(x) = 1;
        end
    
        if mode(epoch.ORIENTATION)==32
            vd.down(x) = 1;
        end
    
        if ~isempty(epoch.ORIENTATION(epoch.ORIENTATION==2))
            vd.hang(x) = 1;
        end
    
        if median(epoch.LIGHT)<=1
            vd.dark(x) = 1;
        end
    
        if mean(epoch.TAT)>0
            vd.move(x) = 1;
        end
    
    end
    
    [predLabel,scores] = predict(Mdl,vd);
    vd.predLabel = predLabel;
    
    vd.LIGHTlog = vd.LIGHT;
    vd.LIGHTlog(vd.LIGHTlog<0.01) = 0.01;
    vd.LIGHTlog = log(vd.LIGHTlog);
    
    figure
    for X = 1:length(Day)
        subplot(length(Day),1,X)
        y = vd.LIGHTlog(vd.day==Day(X));
        x = vd.TIME(vd.day==Day(X));
        xx1 = vd.TIME(vd.day==Day(X) & vd.predLabel=='wear');
        xx2 = vd.TIME(vd.day==Day(X) & vd.predLabel=='non-wear');
        xx3 = vd.TIME(vd.day==Day(X) & vd.predLabel=='night');
        hold on
        plot(x,y,'Color',[1 0.3 0])
        plot(xx2,0.1*ones(size(xx2)),'.k')
        plot(xx3,0.1*ones(size(xx3)),'.b')
        plot(xx1,0.1*ones(size(xx1)),'.r')
        title(string(participants{i}))
        ax = gca; ax.TickDir = 'out'; ax.Box = 'off';
        ax.YLim = [log(0.009) log(120000)]; ax.YTick = log([0.1 1 10 100 1000 10000 100000]); ax.YTickLabels = {'0','1','10','100','1k','10k','100k'};
        
        if X<7
            N = length(vd.TIME(vd.day==Day(X+1) & vd.hour<6 & vd.predLabel=='night'));
            NwN = length(vd.TIME(vd.day==Day(X+1) & vd.hour<6 & vd.predLabel=='non-wear'));
        end
        D = length(vd.TIME(vd.day==Day(X) & vd.hour>10 & vd.hour<22 & vd.predLabel=='wear'));
        NwD = length(vd.TIME(vd.day==Day(X) & vd.hour>10 & vd.hour<22 & vd.predLabel=='non-wear'));
        prctNight(i,X) = N/(NwN+N);
        prctDay(i,X) = D/(NwD+D);
    end

        if prctNight(i,X)>=0.8
            vd.GoodNight = ones(height(vd),1);
        else
            vd.GoodNight = zeros(height(vd),1);
        end
        
        if prctDay(i,X)>=0.8
            vd.GoodDay = ones(height(vd),1);
        else
            vd.GoodDay = zeros(height(vd),1);
        end

    if i==1
        actlumus_mig = vd;
    else
        actlumus_mig = [actlumus_mig;vd];
    end
end

figure
subplot(1,2,1)
histogram(actlumus_mig.GoodDay,'Normalization','probability')

subplot(1,2,2)
histogram(actlumus_mig.GoodNight,'Normalization','probability')

day_min = vd.total_min(vd.day==min(vd.day));
for i = 1:length(day_min)
    goodDay(i,:) = nanmean(actlumus_mig.LIGHTlog(actlumus_mig.GoodDay==1 & actlumus_mig.total_min==day_min(i)));
    goodNight(i,:) = nanmean(actlumus_mig.LIGHTlog(actlumus_mig.GoodNight==1 & actlumus_mig.total_min==day_min(i)));
    badDay(i,:) = nanmean(actlumus_mig.LIGHTlog(actlumus_mig.GoodDay==0 & actlumus_mig.total_min==day_min(i)));
    badNight(i,:) = nanmean(actlumus_mig.LIGHTlog(actlumus_mig.GoodNight==0 & actlumus_mig.total_min==day_min(i)));
end
