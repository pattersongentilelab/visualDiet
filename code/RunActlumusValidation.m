% Organize actlumus validation dataset
data_path = getpref('visualDiet','visualDietDataPath');
addpath '/Users/pattersonc/Documents/MATLAB/commonFx'

load([data_path '/Actlumus/Actlumus validation/mdlRFupdated2.mat'],'Mdl','actlumusAll')

% select dataset
testData = actlumusAll(actlumusAll.trainData==0 & ~isundefined(actlumusAll.wearLabel),:);

trueLabel = testData.wearLabel;
[predLabel,scores] = predict(Mdl,testData);
predLabel = categorical(predLabel);
testers = unique(testData.tester);
fullMdl_accuracyTest = zeros(length(testers), 1);
testData.predLabel = predLabel;
testData.trueLabel = trueLabel;
for i = 1:length(testers)
    fullMdl_accuracyTest(i) = mean(predLabel(testData.tester==testers(i)) ==trueLabel(testData.tester==testers(i)));
end
meanFullAccuracyTest = mean(fullMdl_accuracyTest);
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

testers = unique(testData.tester);

save([data_path '/Actlumus/Actlumus validation/mdlValidateBin1updated.mat'],'rocObj','ss','SS')
%% run model on participants with migraine
load([data_path 'VDS.mat'])

participants = fieldnames(headache_diary);
headache_diary = struct2cell(headache_diary);
actlumus = struct2cell(actlumus);

prctDay = NaN*ones(length(participants),7);
prctNight = NaN*ones(length(participants),7);
NightPlace = NaN*ones(length(participants),7);

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
    
    vd.hang = zeros(height(vd),1);
    vd.up = zeros(height(vd),1);
    vd.down = zeros(height(vd),1);
    vd.move = zeros(height(vd),1);
    vd.dark = zeros(height(vd),1);
    vd.lightlog = log(vd.LIGHT+0.1);
    vd.pimlog = log(vd.PIM+1);
    
    [predLabel,scores] = predict(Mdl,vd);
    vd.predLabel = categorical(predLabel);
    
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
            N = length(vd.TIME(vd.day==Day(X+1) & vd.hour<6 & vd.predLabel~='non-wear'));
            NwN = length(vd.TIME(vd.day==Day(X+1) & vd.hour<6 & vd.predLabel=='non-wear'));
        end
            NwD = length(vd.TIME(vd.day==Day(X) & vd.hour>6 & vd.predLabel=='non-wear'));
            D = length(vd.TIME(vd.day==Day(X) & vd.hour>6 & vd.predLabel~='non-wear'));

        prctAdhere(i,X) = length(vd.TIME(vd.day==Day(X) & vd.predLabel~='non-wear'))./length(vd.TIME(vd.day==Day(X)));
    end

    if i==1
        actlumus_mig = vd;
    else
        actlumus_mig = [actlumus_mig;vd];
    end
end