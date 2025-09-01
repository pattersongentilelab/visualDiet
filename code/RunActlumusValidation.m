% Organize actlumus validation dataset
data_path = getpref('visualDiet','visualDietDataPath');
addpath '/Users/pattersonc/Documents/MATLAB/commonFx'

load([data_path '/Actlumus/Actlumus validation/mdlBin1cpg.mat'],'mdlLR','Mdlsvm','actlumusAll')

bin_size = 1;
model = 1; % 0 = logistic regression, 1 = SVM

% select dataset
validateData = actlumusAll(actlumusAll.testData==0 & ~isundefined(actlumusAll.wearLabel),:);

switch model
    case 0
        Mdl = mdlLR;
    case 1
        Mdl = Mdlsvm;
end

trueLabel = validateData.wearLabel2;
[predLabel,scores] = predict(Mdl,validateData);
rocObj = rocmetrics(trueLabel,scores,Mdl.ClassNames);

figure
plot(rocObj)
CM = confusionmat(trueLabel,predLabel);
figure
confusionchart(CM)

ss = NaN*ones(size(CM,1)+1,1);
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

weartimeT = NaN*ones(length(testers),15);
weartimeP = NaN*ones(length(testers),15);


figure
for x = 1:length(testers)
    t_dates = unique(validateData.DATETIME(validateData.tester==testers(x)));
    for y = 1:length(t_dates)
        tW = length(trueLabel(validateData.tester==testers(x) & validateData.DATETIME==t_dates(y) & trueLabel=='wear'));
        tNw = length(trueLabel(validateData.tester==testers(x) & validateData.DATETIME==t_dates(y) & trueLabel=='non-wear'));
        tNi = length(trueLabel(validateData.tester==testers(x) & validateData.DATETIME==t_dates(y) & trueLabel=='night'));

        pW = length(predLabel(validateData.tester==testers(x) & validateData.DATETIME==t_dates(y) & predLabel=='wear'));
        pNw = length(predLabel(validateData.tester==testers(x) & validateData.DATETIME==t_dates(y) & predLabel=='non-wear'));
        pNi = length(predLabel(validateData.tester==testers(x) & validateData.DATETIME==t_dates(y) & predLabel=='night'));
        
        weartimeT(x,y) = (tW+tNi)/(tW+tNw+tNi);
        weartimeP(x,y) = (pW+pNi)/(pW+pNw+pNi);
    end
    subplot(1,length(unique(validateData.tester)),x)
    hold on
    plot(weartimeT(x,:),weartimeP(x,:),'ok')
    plot([0 1],[0 1],'--')
    ax = gca; ax.TickDir = 'out'; ax.Box = 'off'; ax.XLim = [0 1]; ax.YLim = [0 1];
end

comp = validateData(:,1:2);
comp.trueLabel = trueLabel;
comp.predLabel = predLabel;


%% use predicted labels to define day and night compliance
nightWear = NaN*ones(length(testers),15);
dayWear = NaN*ones(length(testers),15);
for x = 1:length(testers)
    t_dates = unique(validateData.DATETIME(validateData.tester==testers(x)));
    for y = 1:length(t_dates)
        dayWear(x,y) = length(trueLabel(validateData.tester==testers(x) & validateData.DATETIME==t_dates(y) & trueLabel=='wear'));
        
        if y < length(t_dates)
            nightWear(x,y) = length(trueLabel(validateData.tester==testers(x) & ((validateData.DATETIME==t_dates(y) & validateData.MS>='17:00:00')|...
               (validateData.DATETIME==t_dates(y+1) & validateData.MS<='14:00:00')) & trueLabel=='night'));
        else
            nightWear(x,y) = length(trueLabel(validateData.tester==testers(x) & validateData.DATETIME==t_dates(y) & validateData.MS>='17:00:00'...
               & trueLabel=='night'));
        end
    end
end

% save([data_path '/Actlumus/Actlumus validation/mdlValidateBin1.mat'])