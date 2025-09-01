% Build Actlumus Model
data_path = getpref('visualDiet','visualDietDataPath');
addpath '/Users/pattersonc/Documents/MATLAB/commonFx'

load([data_path '/Actlumus/Actlumus validation/actlumusValidationAllbin30.mat'],'actlumusAll')


%% select test data
testData = actlumusAll(actlumusAll.testData==1 & ~isnan(actlumusAll.wear),:);

%% Binomial regression model


mdlLR = fitmnr(testData,'wearLabel2 ~ up + hang + dark + move');
[predLabelLR,scoresMdlLR] = predict(mdlLR,testData);
trueLabelLR = testData.wearLabel2;
rocObjLR = rocmetrics(trueLabelLR,scoresMdlLR,mdlLR.ClassNames,'NumBootstraps',100);
figure
plot(rocObjLR,'ShowConfidenceIntervals',true)
CM = confusionmat(trueLabelLR,predLabelLR);
figure
confusionchart(CM)

ssLR = NaN*ones(size(CM,1),1);
for i = 1:size(CM,1)
    TP = CM(i,i);
    FP = sum(CM(:,i))-TP;
    FN = sum(CM(i,:))-TP;
    TN = sum(sum(CM(:,:)))-(TP+FP+FN);
    ssLR(i,1) = TP/(TP+FN);
    ssLR(i,2) = TN/(TN+FP);
end

%% SVM model

Mdlsvm = fitcecoc(testData,'wearLabel2 ~ up + hang + dark + move','OptimizeHyperparameters','auto');
[~,scoresMdlsvm] = resubPredict(Mdlsvm);
scoreSVM = scoresMdlsvm(:,Mdlsvm.ClassNames);
predLabel = resubPredict(Mdlsvm);
trueLabel = testData.wearLabel2(~isundefined(testData.wearLabel));
rocObjSVM = rocmetrics(trueLabel,scoreSVM,Mdlsvm.ClassNames,'NumBootstraps', 100);
figure
plot(rocObjSVM,'ShowConfidenceIntervals',true)
CM = confusionmat(trueLabel,predLabel);
figure
confusionchart(CM)

ssSVM = NaN*ones(size(CM,1),1);
for i = 1:size(CM,1)
    TP = CM(i,i);
    FP = sum(CM(:,i))-TP;
    FN = sum(CM(i,:))-TP;
    TN = sum(sum(CM(:,:)))-(TP+FP+FN);
    ssSVM(i,:) = TP/(TP+FN);
    ssSVM(i,:) = TN/(TN+FP);
end


save([data_path '/Actlumus/Actlumus validation/mdlBin30cpg.mat'],'mdlLR','rocObjLR','testData','actlumusAll','ssLR'...
  ,'Mdlsvm','rocObjSVM','ssSVM')