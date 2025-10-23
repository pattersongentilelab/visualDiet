% Build Actlumus Model
data_path = getpref('visualDiet','visualDietDataPath');
addpath '/Users/pattersonc/Documents/MATLAB/commonFx'

load([data_path '/Actlumus/Actlumus validation/actlumusValidationAllbin1.mat'],'actlumusAll')

%% select test data
testData = actlumusAll(actlumusAll.testData==1 & ~isnan(actlumusAll.wear),:);

%% Binomial regression model


mdlLR = fitmnr(testData,'wearLabel ~ hang + down + move + LIGHT + daytime');
[predLabelLR,scoresMdlLR] = predict(mdlLR,testData);
trueLabelLR = testData.wearLabel;
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

% Mdlsvm = fitcecoc(testData,'wearLabel ~ down + hang + move + dark + daytime','OptimizeHyperparameters','auto');
% [~,scoresMdlsvm] = resubPredict(Mdlsvm);
% scoreSVM = scoresMdlsvm(:,Mdlsvm.ClassNames);
% predLabel = resubPredict(Mdlsvm);
% trueLabel = testData.wearLabel(~isundefined(testData.wearLabel));
% rocObjSVM = rocmetrics(trueLabel,scoreSVM,Mdlsvm.ClassNames,'NumBootstraps', 100);
% figure
% plot(rocObjSVM,'ShowConfidenceIntervals',true)
% CM = confusionmat(trueLabel,predLabel);
% figure
% confusionchart(CM)
% 
% ssSVM = NaN*ones(size(CM,1),1);
% for i = 1:size(CM,1)
%     TP = CM(i,i);
%     FP = sum(CM(:,i))-TP;
%     FN = sum(CM(i,:))-TP;
%     TN = sum(sum(CM(:,:)))-(TP+FP+FN);
%     ssSVM(i,1) = TP/(TP+FN);
%     ssSVM(i,2) = TN/(TN+FP);
% end

%% outdoor model
testData2 = actlumusAll(~isnan(actlumusAll.indoorReal),:);
mdlIndoor = fitglm(testData2,'indoorReal ~ indoorBlue','Distribution','binomial');
[predLabelIndoor,scoresMdlIndoor] = predict(mdlIndoor,testData2);
trueLabelIndoor = testData2.indoorReal;
rocObjIndoor = rocmetrics(trueLabelIndoor,scoresMdlIndoor(:,1),1);
predLabelIndoor  = round(predLabelIndoor);
figure
plot(rocObjIndoor)

CMindoor = confusionmat(trueLabelIndoor,predLabelIndoor);

ssLR = NaN*ones(size(CMindoor,1),1);
for i = 1:size(CMindoor,1)
    TP = CMindoor(i,i);
    FP = sum(CMindoor(:,i))-TP;
    FN = sum(CMindoor(i,:))-TP;
    TN = sum(sum(CMindoor(:,:)))-(TP+FP+FN);
    ssLR(i,1) = TP/(TP+FN);
    ssLR(i,2) = TN/(TN+FP);
end



save([data_path '/Actlumus/Actlumus validation/mdlBin1cpg4.mat'],'mdlLR','rocObjLR','testData','actlumusAll','ssLR','mdlLRout','rocObjLRout')